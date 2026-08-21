# plot all IDs in the prcocessed dataset stwc in one plot

# create column for palms vs. non-palms, where all species starting with "Dicot" are non-palms
stwc <- stwc %>%
  mutate(cotyl = ifelse(str_starts(species, "Dicot"), "dicotyledonous tree", "monocotlyedonous palm"))

timeseries <- ggplot(stwc, aes(x = timestamp, y = v_stwc, color = species)) +
  geom_line() +
  facet_wrap(~ID, scales = "free_y") +
  labs(title = "Stem water content over time by tree ID",
       x = "",
       y = "Volumetric Stem Water Content (m³/m³)") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_x_datetime(date_breaks = "1 month", date_labels = "%b")

windows();timeseries
#ggsave(timeseries, filename = paste0(DATA_PATH,"plots/", field_loc, "/stem_wc_by_ID_facet.jpg"), width = 12, height = 8)
# plot all IDs in the prcocessed dataset stwc in one plot

p0 <- ggplot(stwc, aes(x = timestamp, y = v_stwc_tcor, color = ID)) +
  geom_line() +
  labs(title = "Temperature Corrected Stem Water Content over Time by Tree ID",
       x = "Timestamp",
       y = "Temperature Corrected Volumetric Stem Water Content (v_stwc_tcor)") +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_x_datetime(date_breaks = "1 month", date_labels = "%b")
windows();p0
#ggsave(p0, filename = paste0(DATA_PATH,"plots/", field_loc, "/temp_corrected_stem_wc_all_IDs.jpg"), width = 10, height = 6)

# sample size labels per cotyl group (count unique trees)
cotyl_n <- stwc %>%
  group_by(cotyl) %>%
  summarize(n = n_distinct(ID), .groups = "drop")

cotyl_labels <- setNames(
  paste0(cotyl_n$cotyl, " (n = ", cotyl_n$n, ")"),
  cotyl_n$cotyl
)

# boxplot of stem water content by cotyl group
bp <- ggplot(stwc, aes(x = cotyl, y = v_stwc_tcor, fill = cotyl)) +
  geom_boxplot() +
  labs(title = "Stem water content by cotyl group measured in the Atlantic Rainforest",
       x = "",
       y = "Volumetric Stem Water Content (m³/m³)") +
  theme_minimal() +
  scale_x_discrete(labels = cotyl_labels) +
 # choose fill colour for boxplots
  scale_fill_manual(values = c("monocotlyedonous palm" = "#22A884FF", "dicotyledonous tree" = "#7057a2ff")) +
  theme(legend.position = "none")
windows();bp
ggsave(bp, filename = paste0(DATA_PATH,"plots/", field_loc, "/stem_wc_by_cotyl_boxplot.jpg"), width = 7, height = 6)

stwc %>%
  group_by(cotyl) %>%
  summarize(mean_stwc = mean(v_stwc_tcor, na.rm = TRUE),
            median_stwc = median(v_stwc_tcor, na.rm = TRUE),
            sd_stwc = sd(v_stwc_tcor, na.rm = TRUE),
            n = n())

# test for difference in stem water content between cotyl groups, t-test, account for ID as random effect
t_test <- t.test(v_stwc_tcor ~ cotyl, data = stwc)
t_test  
#account for random effect
library(lme4)
model <- lmer(v_stwc_tcor ~ cotyl + (1 | ID), data = stwc)
summary(model)
