compute_varna_colors <- function(tbl, out, black = "0", yellow = "0.65", orange = "0.9",
                                 first_base = 1, last_base = nrow(tbl),
                                 col = "Norm_profile") {
  p <- tbl[[col]][first_base:last_base]
  colors <-
    dplyr::case_when(p < 0.4 ~ black, p > 0.85 ~ orange, TRUE ~ yellow )
  colors
}

c1c6 <- readr::read_delim("C1-C7_C_ST9_native_150nt_profile.txt")
compute_varna_colors(c1c6, "C1-C7_C_ST9_native_150nt_profile.colors.txt",
                   first_base = 24, last_base = 77)

c1c6$Sequence|> stringr::str_c(collapse = "")
