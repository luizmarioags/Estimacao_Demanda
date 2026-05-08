# ============================================================
# 00_download_data.R
# Baixa a base broiler/chicken demand usada na lista.
# Fonte principal: MIT OCW mirror do problem set de IO.
# O arquivo é salvo como data/raw/chicken_demand.csv.
# ============================================================

source("R/00_setup.R")

BROILER_URLS <- c(
  "https://mitocw.ups.edu.ec/courses/economics/14-271-industrial-organization-i-fall-2005/assignments/broiler.csv"
)

EXPECTED_COLUMNS <- c(
  "YEAR", "Q", "Y", "PCHICK", "PBEEF", "PCOR", "PF", "CPI",
  "QPRODA", "POP", "MEATEX", "TIME"
)

download_broiler_data <- function(force = FALSE) {
  out_csv <- file.path(RAW_DIR, "chicken_demand.csv")
  mirror_csv <- file.path(RAW_DIR, "broiler.csv")
  source_txt <- file.path(RAW_DIR, "SOURCE_broiler.txt")

  if (file.exists(out_csv) && !force) {
    message("Base já existe em: ", out_csv)
    return(invisible(out_csv))
  }

  last_error <- NULL

  for (url in BROILER_URLS) {
    message("Tentando baixar base de: ", url)
    try_result <- try({
      raw <- readr::read_csv(url, show_col_types = FALSE)
      names(raw) <- toupper(names(raw))

      missing <- setdiff(EXPECTED_COLUMNS, names(raw))
      if (length(missing) > 0) {
        stop("Download realizado, mas variáveis esperadas ausentes: ", paste(missing, collapse = ", "))
      }

      readr::write_csv(raw, out_csv)
      readr::write_csv(raw, mirror_csv)
      writeLines(c(
        "Base: broiler/chicken demand",
        paste0("Fonte baixada: ", url),
        "Descrição: dados anuais de demanda por galeto/frango de corte usados em Epple e McCallum e em exercícios de Economia Industrial.",
        "Arquivo operacional do pacote: data/raw/chicken_demand.csv",
        "Observação: o pacote constrói qc, pf, y, pb e pc em logs a partir das variáveis brutas."
      ), con = source_txt)

      message("Base salva em: ", out_csv)
      invisible(out_csv)
    }, silent = TRUE)

    if (!inherits(try_result, "try-error")) {
      return(invisible(out_csv))
    }

    last_error <- try_result
  }

  stop(
    "Não foi possível baixar a base automaticamente. ",
    "Baixe manualmente broiler.csv e salve como data/raw/chicken_demand.csv. ",
    "Último erro: ", as.character(last_error),
    call. = FALSE
  )
}

if (sys.nframe() == 0) {
  download_broiler_data(force = FALSE)
}
