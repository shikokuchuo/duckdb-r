skip_on_cran()
if (rlang::is_installed("dbplyr")) {
  `%>%` <- dplyr::`%>%`
}

test_that("Parquet files can be registered with dplyr::tbl()", {
  skip_if_not(TEST_RE2)

  skip_if_not_installed("dbplyr")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  tab0 <- dplyr::tbl(con, "data/userdata1.parquet")
  expect_true(inherits(tab0, "tbl_duckdb_connection"))
  expect_true(tab0 %>% dplyr::count() %>% dplyr::collect() == 1000)

  tab1 <- dplyr::tbl(con, "read_parquet(['data/userdata1.parquet'])")
  expect_true(inherits(tab1, "tbl_duckdb_connection"))
  expect_true(tab1 %>% dplyr::count() %>% dplyr::collect() == 1000)

  tab2 <- dplyr::tbl(con, "'data/userdata1.parquet'")
  expect_true(inherits(tab2, "tbl_duckdb_connection"))
  expect_true(tab2 %>% dplyr::count() %>% dplyr::collect() == 1000)

  tab3 <- dplyr::tbl(con, "parquet_scan(['data/userdata1.parquet'])")
  expect_true(inherits(tab3, "tbl_duckdb_connection"))
  expect_true(tab3 %>% dplyr::count() %>% dplyr::collect() == 1000)
})

test_that("Parquet files can be registered with tbl_file() and tbl_function()", {
  skip_if_not_installed("dbplyr")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  tab0 <- tbl_file(con, "data/userdata1.parquet")
  expect_true(inherits(tab0, "tbl_duckdb_connection"))
  expect_true(tab0 %>% dplyr::count() %>% dplyr::collect() == 1000)

  tab1 <- tbl_function(con, "read_parquet(['data/userdata1.parquet'])")
  expect_true(inherits(tab1, "tbl_duckdb_connection"))
  expect_true(tab1 %>% dplyr::count() %>% dplyr::collect() == 1000)

  tab2 <- tbl_function(con, "'data/userdata1.parquet'")
  expect_true(inherits(tab2, "tbl_duckdb_connection"))
  expect_true(tab2 %>% dplyr::count() %>% dplyr::collect() == 1000)

  tab3 <- tbl_function(con, "parquet_scan(['data/userdata1.parquet'])")
  expect_true(inherits(tab3, "tbl_duckdb_connection"))
  expect_true(tab3 %>% dplyr::count() %>% dplyr::collect() == 1000)
})


test_that("Object cache can be enabled for parquet files with dplyr::tbl()", {
  skip_if_not_installed("dbplyr")
  # https://github.com/tidyverse/dbplyr/issues/1384
  skip_if(packageVersion("dbplyr") >= "2.4.0")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  DBI::dbExecute(con, "SET enable_object_cache=False;")
  tab1 <- dplyr::tbl(con, "data/userdata1.parquet", cache = TRUE)
  expect_true(DBI::dbGetQuery(con, "SELECT value FROM duckdb_settings() WHERE name='enable_object_cache';") == "true")

  DBI::dbExecute(con, "SET enable_object_cache=False;")
  tab2 <- dplyr::tbl(con, "'data/userdata1.parquet'", cache = FALSE)
  expect_true(DBI::dbGetQuery(con, "SELECT value FROM duckdb_settings() WHERE name='enable_object_cache';") == "false")
})

test_that("Object cache can be enabled for parquet files with tbl_file() and tbl_function()", {
  skip_if_not_installed("dbplyr")
  # https://github.com/tidyverse/dbplyr/issues/1384
  skip_if(packageVersion("dbplyr") >= "2.4.0")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  DBI::dbExecute(con, "SET enable_object_cache=False;")
  tab1 <- tbl_file(con, "data/userdata1.parquet", cache = TRUE)
  expect_true(DBI::dbGetQuery(con, "SELECT value FROM duckdb_settings() WHERE name='enable_object_cache';") == "true")

  DBI::dbExecute(con, "SET enable_object_cache=False;")
  tab2 <- tbl_function(con, "'data/userdata1.parquet'", cache = FALSE)
  expect_true(DBI::dbGetQuery(con, "SELECT value FROM duckdb_settings() WHERE name='enable_object_cache';") == "false")
})


test_that("CSV files can be registered with dplyr::tbl()", {
  skip_if_not(TEST_RE2)

  skip_if_not_installed("dbplyr")

  path <- file.path(tempdir(), "duckdbtest.csv")
  write.csv(iris, file = path)
  on.exit(unlink(path))

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  tab1 <- dplyr::tbl(con, path)
  expect_true(inherits(tab1, "tbl_duckdb_connection"))
  expect_true(tab1 %>% dplyr::count() %>% dplyr::collect() == 150)

  tab2 <- dplyr::tbl(con, paste0("read_csv_auto('", path, "')"))
  expect_true(inherits(tab2, "tbl_duckdb_connection"))
  expect_true(tab2 %>% dplyr::count() %>% dplyr::collect() == 150)
})

test_that("CSV files can be registered with tbl_file() and tbl_function()", {
  skip_if_not_installed("dbplyr")

  path <- file.path(tempdir(), "duckdbtest.csv")
  write.csv(iris, file = path)
  on.exit(unlink(path))

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  tab1 <- tbl_file(con, path)
  expect_true(inherits(tab1, "tbl_duckdb_connection"))
  expect_true(tab1 %>% dplyr::count() %>% dplyr::collect() == 150)

  tab2 <- tbl_function(con, paste0("read_csv_auto('", path, "')"))
  expect_true(inherits(tab2, "tbl_duckdb_connection"))
  expect_true(tab2 %>% dplyr::count() %>% dplyr::collect() == 150)
})


test_that("Other replacement scans or functions can be registered with dplyr::tbl()", {
  skip_if_not(TEST_RE2)

  skip_if_not_installed("dbplyr")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  obj <- dplyr::tbl(con, "duckdb_keywords()")
  expect_true(inherits(obj, "tbl_duckdb_connection"))
  expect_true(obj %>% dplyr::filter(keyword_name == "all") %>% dplyr::count() %>% dplyr::collect() == 1)
})

test_that("Other replacement scans or functions can be registered with tbl_function()", {
  skip_if_not_installed("dbplyr")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  obj <- tbl_function(con, "duckdb_keywords()")
  expect_true(inherits(obj, "tbl_duckdb_connection"))
  expect_true(obj %>% dplyr::filter(keyword_name == "all") %>% dplyr::count() %>% dplyr::collect() == 1)
})


test_that("Strings tagged as SQL will be handled correctly with dplyr::tbl()", {
  skip_if_not_installed("dbplyr")

  con <- DBI::dbConnect(duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  rs <- dplyr::tbl(con, dplyr::sql("SELECT 1"))
  expect_true(inherits(rs, "tbl_duckdb_connection"))
  expect_true(rs %>% dplyr::collect() == 1)
})

try(rm(`%>%`))
