p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	filter(year(date) <= 2023) %>%
	filter(date > max(date)-42) %>%
	pivot_longer(c(new_icu, new_nonicu), names_prefix = "new_") %>%
	mutate(name = str_replace_all(name, "icu", "ICU") %>% str_replace_all("non", "Non-")) %>%
	ggplot(aes(x = date, y = value)) +
	geom_line(size = 1) +
	geom_point(data = . %>% group_by(name) %>% filter(date == max(date)), size = 3) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = value), linetype = 3) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis()) +
	scale_x_date(date_labels = "%b\n%d", date_breaks = "2 weeks", expand = expansion(mult = c(0.10, 0.10))) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	facet_wrap(vars(name), ncol = 2, scales = "free_y") +
	coord_cartesian(clip = "off") +
	theme_covidmn() +
	theme(axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "New ICU and non-ICU COVID hospitalizations in MN",
		 subtitle = "By admission date, for the last six weeks. The most recent week of<br>data is incomplete and omitted.",
		 caption = caption,
		 y = "New admissions")
fix_ratio(p) %>% image_write(here("images/new-hospital-admissions-both-trunc.png"))
