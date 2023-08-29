compute_varna_colors <- function(tbl, black = "0", yellow = "0.65", orange = "0.9",
                                 first_base = 1, last_base = nrow(tbl),
                                 col = "Norm_profile") {
  p <- tbl[[col]][first_base:last_base]
  colors <-
    dplyr::case_when(p < 0.4 ~ black, p > 0.85 ~ orange, TRUE ~ yellow )
  colors
}

filter_norm_profile <- function(tbl, min = -.2, max = 1,
                                first_base = 1, last_base = nrow(tbl),
                                col = "Norm_profile") {
  p <- tbl[[col]][first_base:last_base]
  colors <-
    dplyr::case_when(p < min ~ min, p > max ~ max, TRUE ~ p)
  as.character(colors)
}

c1c6 <- readr::read_delim("data/intermediate/C1-C7_C_ST9_native_150nt_profile.txt")
compute_varna_colors(c1c6, first_base = 24, last_base = 77) |>
  writeLines("results/intermediate/C1-C7_C_ST9_native_150nt_profile.colors.txt")

# range is -2-9.2, but this should only be 0-1. Why?
filter_norm_profile(c1c6, max = Inf, min = -Inf, first_base = 24, last_base = 77) |>
  writeLines("results/intermediate/C1-C7_C_ST9_native_150nt_profile.grad_colors_all.txt")

filter_norm_profile(c1c6, first_base = 24, last_base = 77) |>
  writeLines("results/intermediate/C1-C7_C_ST9_native_150nt_profile.grad_colors_capped.txt")

alpha <- readr::read_delim("data/intermediate/test_alpha-140_profile.txt")
compute_varna_colors(alpha, first_base = 19, last_base = 99) |>
  writeLines("results/intermediate/test_alpha-profile.colors.txt")

filter_norm_profile(alpha, max = Inf, min = -Inf, first_base = 19, last_base = 99) |>
  writeLines("results/intermediate/test_alpha-profile.colors_all.txt")

filter_norm_profile(alpha, first_base = 19, last_base = 99) |>
  writeLines("results/intermediate/test_alpha-profile.colors_capped.txt")
