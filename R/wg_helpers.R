# Return the maximum depth (or levels) of a list
# From: https://stackoverflow.com/questions/13432863/determine-level-of-nesting-in-r
list_depth <- function(input_list) {
    ifelse(is.list(input_list),
           1L + max(sapply(input_list, list_depth)),
           0L)
}

#' Return attribute (column) metadata from a Dataone Metadata object.
#'
#' @description Return attribute metadata from an EML object. This is largely a
#' wrapper for the function \code{get_attributes} from the EML Package
#' \url{https://github.com/ropensci/EML}.
#'
#' @param eml (S4) EML object.
#' @return (list) A list of all attribute metadata from the EML in data.frame objects
#'
#' @export
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' @examples
#' \dontrun{
#' cn <- dataone::CNode('PROD')
#' mn <- dataone::getMNode(cn, 'urn:node:ARCTIC')
#' eml <- EML::read_eml(rawToChar(dataone::getObject(mn, "doi:10.18739/A23W02")))
#' attributes <- datamgmt::get_eml_attributes(eml)
#'
#' # switch nodes
#' cn <- dataone::CNode('PROD')
#' knb <- dataone::getMNode(cn,"urn:node:KNB")
#' eml <- EML::read_eml(rawToChar(dataone::getObject(knb, "doi:10.5063/F1639MWV")))
#' attributes <- get_eml_attributes("doi:10.5063/F1639MWV")
#' }
get_eml_attributes <- function(eml) {
    # TODO - make sure it works for otherEntities
    stopifnot(isS4(eml))

    indices <- vector("numeric")
    indices <- which_in_eml(eml@dataset@dataTable,
                            "attributeList",
                            function(x) {length(x) > 0})

    names <- vector("character", length = length(indices))
    results <- vector("list", length = length(indices))

    for (i in seq_along(indices)) {
        results[[i]] <- EML::get_attributes(eml@dataset@dataTable[[i]]@attributeList)
        names[i] <- eml@dataset@dataTable[[i]]@entityName
    }

    names(results) <- names

    # Unlist results if depth (levels) > 2
    if (list_depth(results) > 2) {
        results <- unlist(results, recursive = FALSE)
    }

    return(results)
}

#' Download attribute (column) metadata from a Dataone Metadata object to csvs.
#'
#' @description Download attribute metadata from an EML object as csvs. The name
#' of each csv corresponds to the file name of the Data Object it describes.
#' This can be prepended with the package identifier by setting \code{prefix_file_names = TRUE} (recommended).
#'
#' @param eml (S4) EML object.
#' @param download_directory (character) Directory to download attribute metadata csv's to.
#' @param prefix_file_names (logical) Optional.  Whether to prefix file names with the package metadata identifier.  This is useful when downloading files from multiple packages to one directory.
#'
#' @export
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' @examples
#' \dontrun{
#  cn <- dataone::CNode('PROD')
#' mn <- dataone::getMNode(cn, 'urn:node:ARCTIC')
#' eml <- EML::read_eml(rawToChar(dataone::getObject(mn, "doi:10.18739/A23W02")))
#' attributes <- datamgmt::download_eml_attributes(eml, download_directory = tempdir(),
#' prefix_file_names = TRUE)
#'}
download_eml_attributes <- function(eml,
                                    download_directory,
                                    prefix_file_names = FALSE) {
    stopifnot(isS4(eml))
    stopifnot(file.exists(download_directory))
    stopifnot(is.logical(prefix_file_names))


    attributes <- get_eml_attributes(eml)

    prefix <- character(0)
    if (prefix_file_names == TRUE) {
        prefix <- EML::eml_get(eml, "packageId") %>%
            as.character() %>%
            remove_special_characters() %>%
            paste0("_")
    }

    file_names <- paste0(prefix, names(attributes)) %>%
        gsub(pattern = "\\..*\\.", replacement = "_") %>%
        paste0(".csv")

    file_paths <- file.path(download_directory, file_names)

    for (i in seq_along(attributes)) {
        if (!is.null(attributes[[i]])) {
            write.csv(data.frame(attributes[[i]]), file = file_paths[i], row.names = FALSE)
        }
    }

    return(invisible())
}

#' Return attribute (column) metadata from a Dataone Package URL.
#'
#' @description Return attribute metadata from an EML object or Dataone Package URL.
#' This is largely a wrapper for the function \code{get_attributes} from the EML Package
#' \url{https://github.com/ropensci/EML}.
#'
#' @param mn (MNode/CNode) The Dataone Node that stores the Metadata object, from \url{https://cn.dataone.org/cn/v2/node}
#' @param url_path (character) The url of the Dataone Package.
#' @param write_to_csv (logical) Optional. Option whether to download the attribute metadata to csv's.  Defaults to \code{FALSE}
#' @param prefix_file_names (logical) Optional.  Whether to prefix file names with the package metadata identifier.
#' This is useful when downloading files from multiple packages to one directory.
#' @param download_directory (character) Optional.  Directory to download attribute metadata csv's to.
#' Required if \code{write_to_csv} is \code{TRUE}
#' @return (list) A list of all attribute metadata from the EML in data.frame objects
#'
#' @export
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' @examples
#' \dontrun{
#' attributes <- get_eml_attributes(mn,
#' "https://arcticdata.io/catalog/#view/doi:10.18739/A23W02")
#'
#' # Download attribute metadata in csv format:
#' attributes <- get_eml_attributes(mn,
#' "https://arcticdata.io/catalog/#view/doi:10.18739/A23W02",
#' write_to_csv = TRUE,
#' download_directory = tempdir())

#' # switch nodes
#' cn <- dataone::CNode('PROD')
#' knb <- dataone::getMNode(cn,"urn:node:KNB")
#' attributes <- get_eml_attributes(knb,
#' "https://knb.ecoinformatics.org/#view/doi:10.5063/F1639MWV")
#' }
get_eml_attributes_url <- function(mn,
                                   url_path,
                                   write_to_csv = FALSE,
                                   prefix_file_names = FALSE,
                                   download_directory = NULL) {
    stopifnot(methods::is(mn, "MNode"))
    stopifnot(is.character(url_path))
    stopifnot(is.logical(write_to_csv))
    if (!is.null(download_directory)){
        stopifnot(is.character(download_directory))
        stopifnot(file.exists(download_directory))
    }

    pid <- unlist(strsplit(url_path, "view/"))[[2]]
    eml <- EML::read_eml(rawToChar(dataone::getObject(mn, pid)))

    if (write_to_csv == TRUE) {
        download_eml_attributes(eml, download_directory, prefix_file_names)
    }

    results <- get_eml_attributes(eml)

    return(results)
}

#' Remove and substitute special characters in a string.
#'
#' This is a helper function for the 'download_package' function.  This was
#' created as a helper so that users can edit the helper, rather than 'download_package'
#' if they want differing special character substitions.  Substitues special
#' characters from a package identifier. Can be generalized for use with any pid.
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' @param pid (character) The identifier a dataOne object.
#'
#' @return (character) The formatted identifer as a string
remove_special_characters <- function(pid) {
    pid <- pid %>%
        gsub(":", "", .) %>%
        gsub("\\/", "", .) %>%
        gsub("\\.", "", .)

    return(pid)
}

#' Convert excel workbook to multiple csv files
#'
#' This is a helper function for download_package.
#'
#' @param path (character) File location of the excel workbook.
#' @param prefix (character) Optional prefix to prepend to the file name.
#'
#' @author Dominic Mullen \email{dmullen17@@gmail.com}
#'
#' @return (invisible())
excel_to_csv_prefix <- function(path, prefix) {
    stopifnot(file.exists(path))

    # Try to read excel file and split into csvs
    tryCatch({
        sheets <- excel_sheets(path)

        excel_name <- basename(path)
        excel_name <- gsub("\\.xls[x]?$", "", excel_name, ignore.case = TRUE)

        lapply(seq_along(sheets), function(i) {
            csv = read_excel(path, sheet = sheets[i])

            if (length(prefix) > 0) {
                excel_name <- gsub(prefix, "", excel_name)

                if (length(sheets) == 1) {
                    file_name <- paste0(prefix, "_", excel_name, ".csv")
                } else {
                    file_name <- paste0(prefix, "_", excel_name, "_", sheets[i], ".csv")
                }

            } else {
                if (length(sheets) == 1) {
                    file_name <- paste0(excel_name, ".csv")
                } else {
                    file_name <- paste0(excel_name, "_", sheets[i], ".csv")
                }
            }

            file_path <- file.path(dirname(path), file_name)

            utils::write.csv(csv, file_path , row.names = FALSE)})

    },
    error = function(e) {message("Error converting: ", path, " to csv\n")}
    )

    return(invisible())
}

#' Append one list to another.
#'
#' This function appends one list to another list. It can also be used to
#' prepend, just reverse the order of the lists.
#'
#' @param list1 (list) The list to append to.
#' @param list2 (list) The list being appended.
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' @examples
#' \dontrun{
#' appended_lists <- append_lists(list(1:3), list("a", "b", mean))
#' }
#'
append_lists <- function(list1, list2) {
    # TODO Make this function handle infinite lists

    stopifnot(is.list(list1))
    stopifnot(is.list(list2))
    stopifnot(length(list1) > 0)
    stopifnot(length(list2) > 0)

    n1 <- length(list1)
    n2 <- length(list2)

    for (i in 1:n2) {
        list1[[n1+i]] <- list2[[i]]
    }

    return(list1)
}

#' Calculate the total size (in bytes) of the Objects in a Data Package
#'
#' @param mn (MNode/CNode) The Node to query for Object sizes
#' @param resource_map_pid (character) The identifier of the Data Package's Resource Map
#' @param formatType (character) Optional. Filter to just Objects of the given formatType. One of METADATA, RESOURCE, or DATA or * for all types
#'
#' @author Bryce Mecum
#'
#' @return (numeric) The sum of all Object sizes in the Data Package
get_package_size <- function(mn, resource_map_pid, formatType = "*") {
    size_query <- dataone::query(mn,
                                 paste0("q=resourceMap:\"",
                                        resource_map_pid,
                                        "\"+AND+formatType:",
                                        formatType, "&fl=size"),
                                 as = "data.frame")

    if (nrow(size_query) == 0) {
        return(0)
    }

    sum(as.integer(size_query$size))
}

#' Format bytes to human readable format
#'
#' This is a helper function for 'download_package'
#'
#' @param download_size (numeric) Total size in bytes
convert_bytes <- function(download_size) {
    #' TODO - make this function more robust using gdata::humanReadable as a template
    stopifnot(is.numeric(download_size))

    if (download_size >= 1e+12) {
        download_size <- round(download_size/(1e+12), digits = 2)
        unit = " terabytes"
    } else if (1e+12 > download_size & download_size >= 1e+9) {
        download_size <- round(download_size/(1e+9), digits = 2)
        unit = " gigabytes"
    } else if (1e+9 > download_size & download_size >= 1e+6) {
        download_size <- round(download_size/(1e+6), digits = 2)
        unit = " megabytes"
    } else if (1e+6 > download_size) {
        download_size = round(download_size/1000, digits = 2)
        unit = " kilobytes"
    }

    return(paste0(download_size, " ", unit))
}

#' Download multiple data objects using their pids.
#'
#' @description Download mutiple dataone objects.  This is a helper function
#' for 'datamgmt::download_package'
#' @param mn (MNode) The Dataone Member Node to download the data objects from.
#' @param data_pids (character) A vector of Data object pids.
#' @param out_paths (character) A vector of file paths to download to.
#' @param n_max (numeric) Optional.  Number of attempts at downloading a Data object.
download_data_objects <- function(mn, data_pids, out_paths, n_max = 3) {
    stopifnot(methods::is(mn, "MNode"))
    stopifnot(is.character(data_pids))

    for (i in seq_along(out_paths)) {

        if (file.exists(out_paths[i])) {
            warning(call. = FALSE,
                    paste0("The file ", out_paths[i], " already exists. Skipping download."))
        } else {
            n_tries <- 0
            dataObj <- "error"

            while (dataObj[1] == "error" & n_tries < n_max) {
                dataObj <- tryCatch({
                    dataone::getObject(mn, data_pids[i])
                }, error = function(e) {return("error")})

                n_tries <- n_tries + 1
            }
            writeBin(dataObj, out_paths[i])
        }
    }

    return(invisible())
}

#' Download one Package without its child Packages.
#'
#' This function downloads all of the Data Objects in a Data Package to the local filesystem.
#' It is particularly useful when a Data Package is too large to download using the web interface.
#'
#' @param mn (MNode) The Member Node to download from.
#' @param resource_map_pid (chraracter) The identifier of the Resource Map for the package to download.
#' @param download_directory (character) The path of the directory to download the package to.
#' @param prefix_file_names (logical) Optional.  Whether to prefix file names with the package metadata identifier.  This is useful when downloading files from multiple packages to one directory.
#' @param download_column_metadata (logical) Optional.  Whether to download attribute (column) metadata as csvs.  If using this its recommened to also set \code{prefix_file_names = TRUE}
#' @param convert_excel_to_csv (logical) Optional. Whether to convert excel files to csv(s).  This is not recommended if the separate csv files already exist in the package. The csv files are downloaded as sheetName_excelWorkbookName.csv
#'
#' @importFrom utils setTxtProgressBar txtProgressBar write.csv
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#'@examples
#' \dontrun{
#' cn <- CNode("PROD")
#' mn <- getMNode(cn, "urn:node:ARCTIC")
#' download_one_package(mn, "resource_map_doi:10.18739/A2028W", "/home/dmullen")
#' }
#'
download_one_package <- function(mn,
                                 resource_map_pid,
                                 download_directory,
                                 prefix_file_names = TRUE,
                                 download_column_metadata = FALSE,
                                 convert_excel_to_csv = FALSE) {
    # TODO Add option for downloading in folder structure that mirrors nesting
    # rather than only all files in one folder
    # TODO Convert check download size to helper function?

    # Check that input arguments are in the correct format
    stopifnot(methods::is(mn, "MNode"))
    stopifnot(is.character(resource_map_pid))
    stopifnot(file.exists(download_directory))
    stopifnot(is.logical(prefix_file_names))
    stopifnot(is.logical(download_column_metadata))
    stopifnot(is.logical(convert_excel_to_csv))
    if (convert_excel_to_csv == TRUE) {
        # Stop if the user doesn't have the readxl package installed
        if (!requireNamespace("readxl")) {
            stop(call. = FALSE,
                 "The readxl package is required to show progress. Please install it and try again.")
        }
    }
    # Get package pids
    package <- arcticdatautils::get_package(mn, resource_map_pid, file_names = TRUE)

    # Initialize data_pids, return if no data present
    if (length(package$data) == 0) {
        return(invisible())
    } else {
        data_pids <- package$data
    }

    # Create file names
    # file_names <- sapply(names(data_pids), function(i) {
    #     ifelse(is.na(file_names[i]),
    #            gsub('[^[:alnum:]]', '_', package$data[i]),
    #            file_names[i])})

    file_names <- names(data_pids)
    prefix <- character(0)
    if (prefix_file_names == TRUE) {
        prefix <- remove_special_characters(package$metadata)
        file_names <- paste0(prefix, "_", file_names)
    }
    out_paths <- file.path(download_directory, file_names)

    download_data_objects(mn, data_pids, out_paths)

    if (download_column_metadata == TRUE) {
        eml <- EML::read_eml(rawToChar(dataone::getObject(mn, package$metadata)))
        download_eml_attributes(eml, download_directory, prefix_file_names)
    }

    if (convert_excel_to_csv == TRUE) {
        indices <- which(sapply(out_paths, grepl, pattern = ".xls"))
        excel_paths <- out_paths[indices]
        sapply(excel_paths, excel_to_csv_prefix, prefix = prefix)
    }

    return(invisible())
}

#' Download a Data Package, with its (optional child_packages).
#'
#' This function downloads all of the Data Objects in a Data Package to the local filesystem.
#' It is particularly useful when a Data Package is too large to download using the web interface.
#'
#' Setting \code{check_download_size} to \code{TRUE} is recommended if you are uncertain of the total download size and want to avoid downloading very large Data Packages.
#'
#' This function will also download any data objects it finds in any child Data Packages of the input data package.
#' If you would only like to download data from one Data Package, set \code{download_child_packages} to \code{FALSE}.
#'
#' @param mn (MNode) The Member Node to download from.
#' @param resource_map_pid (chraracter) The identifier of the Resource Map for the package to download.
#' @param download_directory (character) The path of the directory to download the package to.
#' @param prefix_file_names (logical) Optional.  Whether to prefix file names with the package metadata identifier.  This is useful when downloading files from multiple packages to one directory.
#' @param download_column_metadata (logical) Optional.  Whether to download attribute (column) metadata as csvs.  If using this, then its recommened to also set \code{prefix_file_names = TRUE}
#' @param convert_excel_to_csv (logical) Optional. Whether to convert excel files to csv(s).  The csv files are downloaded as sheetName_excelWorkbookName.csv
#' @param download_child_packages (logical) Optional.  Whether to download data from child packages of the selected package. Defaults to \code{TRUE}
#' @param check_download_size (logical) Optional.  Whether to check the total download size before continuing.  Setting this to FALSE speeds up the function, especially when the package has many elements.
#'
#' @importFrom utils setTxtProgressBar txtProgressBar write.csv
#'
#' @export
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' @examples
#' \dontrun{
#' cn <- CNode("PROD")
#' mn <- getMNode(cn, "urn:node:ARCTIC")
#' download_package(mn, "resource_map_urn:uuid:2b4e4174-4e4b-4a46-8ab0-cc032eda8269",
#' "/home/dmullen")
#' }
#'
download_package <- function(mn,
                             resource_map_pid,
                             download_directory,
                             prefix_file_names = TRUE,
                             download_column_metadata = FALSE,
                             convert_excel_to_csv = FALSE,
                             download_child_packages = TRUE,
                             check_download_size = FALSE) {

    stopifnot(methods::is(mn, "MNode"))
    stopifnot(is.character(resource_map_pid))
    stopifnot(file.exists(download_directory))
    stopifnot(is.logical(prefix_file_names))
    stopifnot(is.logical(download_column_metadata))
    stopifnot(is.logical(convert_excel_to_csv))
    if (convert_excel_to_csv == TRUE) {
        # Stop if the user doesn't have the readxl package installed
        if (!requireNamespace("readxl")) {
            stop(call. = FALSE,
                 "The readxl package is required to show progress. Please install it and try again.")
        }
    }
    stopifnot(is.logical(download_child_packages))
    stopifnot(is.logical(check_download_size))

    package <- arcticdatautils::get_package(mn, resource_map_pid)

    if (download_child_packages == TRUE) {
        packages <- c(package$resource_map, package$child_packages)
    }

    progressBar <- utils::txtProgressBar(0, length(packages), style = 3)

    sapply(seq_along(packages), function(i) {
        message("\nDownloading data from package ", packages[i], "\n")

        download_one_package(mn = mn,
                             resource_map_pid = packages[i],
                             download_directory = download_directory,
                             prefix_file_names = prefix_file_names,
                             download_column_metadata = download_column_metadata,
                             convert_excel_to_csv = convert_excel_to_csv)

        utils::setTxtProgressBar(progressBar, i)
    })

    return(invisible())
}

#' Download one or multiple Data Packages
#'
#' This function is wrapper for download_package It downloads all of the Data Objects in a Data Package
#' to the local filesystem.  It is particularly useful when a Data Package is too large to download using
#' the web interface.
#'
#' Setting \code{check_download_size} to \code{TRUE} is recommended if you are uncertain of the total download size and want to avoid downloading very large Data Packages.
#'
#' This function will also download any data objects it finds in any child Data Packages of the input data package.
#' If you would only like to download data from one Data Package, set \code{download_child_packages} to \code{FALSE}.
#'
#' @param mn (MNode) The Member Node to download from.
#' @param resource_map_pids (chraracter) The identifiers of the Resource Maps for the packages to download.
#' @param download_directory (character) The path of the directory to download the packages to.
#' @param ... Allows arguments from \code{\link{download_package}}
#'
#' @author Dominic Mullen, \email{dmullen17@@gmail.com}
#'
#' \code{\link{download_package}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' cn <- CNode("PROD")
#' mn <- getMNode(cn, "urn:node:ARCTIC")
#' download_packages(mn, c("resource_map_doi:10.18739/A21G1P", "resource_map_doi:10.18739/A2RZ6X"),
#' "/home/dmullen/downloads", prefix_file_names = TRUE, download_column_metadata = TRUE,
#' convert_excel_to_csv = TRUE)
#' }
download_packages <- function(mn, resource_map_pids, download_directory, ...) {

    stopifnot(methods::is(mn, "MNode"))
    stopifnot(all(is.character(resource_map_pids)))
    stopifnot(length(resource_map_pids) > 0)
    stopifnot(file.exists(download_directory))

    n_packages <- length(resource_map_pids)

    lapply(seq_len(n_packages), function(i) {
        message("Downloading package ", i, "/", n_packages)
        download_package(mn, resource_map_pids[i], download_directory, ...)})

    return(invisible())
}

#' Search through EMLs
#'
#' This function returns indices within an EML list that contain an instance where \code{test == TRUE}. See examples for more information.
#'
#' @import EML
#' @param eml_list (S4/List) an EML list object
#' @param element (character) element to evaluate
#' @param test (function/character) A function to evaluate (see examples). If test is a character, will evaluate if \code{element == test} (see example 1).
#'
#' @keywords eml
#'
#' @examples
#' \dontrun{
#' # Question: Which creators have a surName "Smith"?
#' n <- which_in_eml(eml@@dataset@@creator, "surName", "Smith")
#' # Answer: eml@@dataset@@creator[n]
#'
#' # Question: Which dataTables have an entityName that begins with "2016"
#' n <- which_in_eml(eml@@dataset@@dataTable, "entityName", function(x) {grepl("^2016", x)})
#' # Answer: eml@@dataset@@dataTable[n]
#'
#' # Question: Which attributes in dataTable[[1]] have a numberType "natural"?
#' n <- which_in_eml(eml@@dataset@@dataTable[[1]]@@attributeList@@attribute, "numberType", "natural")
#' # Answer: eml@@dataset@@dataTable[[1]]@@attributeList@@attribute[n]
#'
#' #' # Question: Which dataTables have at least one attribute with a numberType "natural"?
#' n <- which_in_eml(eml@@dataset@@dataTable, "numberType", function(x) {"natural" %in% x})
#' # Answer: eml@@dataset@@dataTable[n]
#' }
#' @export
#'
#' @author Mitchell Maier
#'
which_in_eml <- function(eml_list, element, test) {

    stopifnot(isS4(eml_list))
    stopifnot(methods::is(eml_list,"list"))
    stopifnot(is.character(element))

    if (is.character(test)) {
        value = test
        test = function(x) {x == value}

    } else {
        stopifnot(is.function(test))
    }

    # Find location
    location <- unlist(lapply(seq_along(eml_list), function(i) {
        elements_test <- unlist(EML::eml_get(eml_list[[i]], element))

        if (is.null(elements_test)) {
            out <- NULL

        } else {
            result <- test(elements_test)

            if (length(result) > 1) {
                stop("Test must only return one value.")

            } else if (result == TRUE) {
                out <- i

            } else {
                out <- NULL
            }
        }
        return(out)
    }))

    return(location)
}
