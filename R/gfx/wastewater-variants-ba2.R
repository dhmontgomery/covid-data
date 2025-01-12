p <- wastewater_variants_nominal %>%
	mutate(variant = case_when(variant == "Omicron BA.2 (Excluding BA.2.12.1)" ~ "Omicron BA.2", 
							   variant == "Omicron BA.5 (Excluding BQ.1)" ~ "Omicron BA.5", 
							   TRUE ~ variant)) %>%
	# filter(str_detect(variant, "Omicron BA.2|BA.4|BA.5|BQ")) %>%# View()
	filter(date >= current_report_date - 200) %>%
	ggplot(aes(x = date, y = copies_7day, color = variant)) +
	geom_line(aes(y = copies_gapfill), size = .3) +
	geom_line(size = 1.5) +
	# geom_text_repel(data = . %>% group_by(variant) %>% slice_max(copies_7day, with_ties = FALSE), 
	# 		  aes(label = variant), hjust = 1, vjust = -.2, size = 5, direction = "y", fontface = "bold") +
	scale_x_date(date_breaks = "1 month", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	scale_y_continuous(sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.05)),
					   labels = comma_format(accuracy = 1)) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	guides(color = guide_legend(override.aes = list(size = 3))) +
	coord_cartesian(clip = "off") +
	theme_covidmn_line() +
	theme(axis.title.y = element_blank(),
		  legend.position = c(.2, .8)) +
	labs(title = "Omicron variant load in Twin Cities wastewater",
		 caption = "Source: Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery | MPR News",
		 subtitle = "Copies per day per million people",
		 color = "Variant")
fix_ratio(p) %>% image_write(here("images/wastewater-variants-ba2.png"))