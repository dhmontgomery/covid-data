p <- vaccine_1x_gender %>%
	group_by(report_date) %>%
	summarize(across(is.numeric, sum, na.rm = TRUE, .names = '{str_replace_all({.col}, "people_", "total_vax_")}')) %>%
	arrange(report_date) %>%
	transmute(date = report_date, (across(c(-date, -report_date), ~. - lag(.), .names = '{str_replace_all({.col}, "total_", "new_")}'))) %>% 
	full_join(tibble(date = seq(from = min(vaccine_1x_gender$report_date), to = max(vaccine_1x_gender$report_date), by = "day")),
			  by = "date") %>% 
	arrange(date) %>%
	filter(date > min(date)) %>%
	mutate(day_avg = case_when(is.na(new_vax_complete) ~ 0, TRUE ~ 1)) %>%
	mutate(day_avg = rollsumr(day_avg, 7, fill = "extend")) %>%
	filter(!is.na(new_vax_complete)) %>%
	filter(day_avg > 0) %>%
	arrange(date) %>%
	mutate(new_vax_complete = rollmean_new(new_vax_complete, day_avg)) %>%
	filter(new_vax_complete >= 0, new_vax_complete < 100000) %>%
	# filter(date >= as_date("2022-04-01")) %>%
	ggplot(aes(x = date, y = new_vax_complete)) +
	geom_line(size = 1.5) + 
	geom_hline(data = . %>% group_by(name) %>% filter(date == max(date)), 
			   aes(yintercept = value, color = name), linetype = 3) +
	geom_point(data = . %>% group_by(name) %>% filter(date == max(date)), size = 3) +
	scale_color_manual(values = covidmn_colors[c(2, 1, 3)]) + 
	scale_y_continuous(labels = comma_format(scale = 0.001, accuracy = 1, suffix = "K"), sec.axis = dup_axis(), 
					   expand = expansion(mult = c(0, 0.03)), breaks = seq(0, 100000, 5000)) +
	scale_x_date(expand = expansion(mult = .02), date_labels = "%b", date_breaks = "1 month") +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(legend.position = "none",
		  axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.title = element_markdown()) +
	labs(title = "New MN <span style='color:#56B4E9'>first</span>, <span style='color:#E69F00'>final</span> and <span style='color:#009E73'>booster</span> doses, by day",
		 subtitle = "Lines represent seven-day averages",
		 caption = caption)

fix_ratio(p) %>% image_write(here("images/new-first-second-doses.png"))