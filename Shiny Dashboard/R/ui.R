## Dominic Mullen
## 7/7/2016

library(shinydashboard)
library(shinyBS)  # comment out if uploading to server 

##=============================================
## Create sidebar 
##=============================================
sidebar <- dashboardSidebar(
  hr(),  # aesthetic spacing
  sidebarMenu(id = "tabs",
              menuItem("Summary", tabName = "summary", icon = icon("bookmark"), selected = T),
              menuItem("BOD Reporting", tabName = "bod_reporting", icon = icon("table"),
                       menuSubItem("Acquisition", tabName = "acquisition", icon = icon("user-plus")),
                       menuSubItem("Activity", tabName = "activity", icon = icon("bullseye")),
                       menuSubItem("Churn", tabName = "churn", icon = icon("user-times")), 
                       menuSubItem("Engagement", tabName = "engagement", icon = icon("diamond")),
                       menuSubItem("Monetization", "monetization", icon = icon("dollar")),
                       menuSubItem("Retention & Reactivation", tabName = "retention_and_reactivation", icon = icon("users"))
                       ),  # end of BOD sub-tabs 
              menuItem("Ascension", tabName = "ascension", icon = icon("line-chart"),
                       menuSubItem("DAU Stats", tabName = "dau_stats"),
                       menuSubItem("Levels", tabName = "levels"),
                       menuSubItem("Miscellaneous", tabName = "miscellaneous")),
              menuItem("Ping Reporting", tabName = "pingreporting", icon = icon("signal"),
                       menuSubItem("General Overview", tabName = "general_overview", icon = icon("circle")),
                       menuSubItem("All pings: 4 Buckets", tabName = "all_pings_4_buckets", icon = icon("circle")),
                       menuSubItem("Max ping: 4 Buckets", tabName = "max_ping_4_buckets", icon = icon("circle")),
                       menuSubItem("All Pings: 21 Buckets", tabName = "all_pings_21_buckets", icon = icon("circle")),
                       menuSubItem("Pings > 250ms", tabName = "pings_250ms", icon = icon("bar-chart-o"))
                       ),
              menuItem("Projects", tabName = "projects", icon = icon("beer"),
                       menuSubItem("Churn", tabName = "churn"),
                       menuSubItem("Spender Conversion", tabName = "spender_conversion"),
                       menuSubItem("Lifetime Value", tabName = "lifetime_value"),
                       menuSubItem("Skins Analysis", tabName = "skins_analysis", icon = icon("black-tie")))

  )
)


##=============================================
## Create Body 
##=============================================
body <- dashboardBody(
  tabItems(
    tabItem(tabName = "summary",
            fluidRow(
              column(width = 12, 
                     box(width = NULL, height = "600px",
                         title = "SEMC Reporting Dashboard Contents & Overview", solidHeader = T, status = "primary",
                         span(tags$b("Board of Directors (BoD) Reporting:"), style = "color:blue"), br(),
                         "Contains reporting on Acquisition, Activity, Engagement, and Monetization", br(),
                         "BoD Reporting groups data by rolling trailing 28 day periods, based on deployment length", br(),
                         br(),
                         span(tags$b("Ascension Reporting:"), style = "color:blue"), br(),
                         "Contains reporting on Cards, Glory, ICE, Essence, Tokens and Buffs, normalize by DAU", br(),                         
                         "Average Level-up times (hours and minutes) are reported by gameplay time and real world time", br(), 
                         "An ascension level distribution is provided as well as a rate of active users not claiming an acesnion reward ", br(),
                         br(),    
                         span(tags$b("Ping Reporting:"), style = "color:blue"), br(),
                         "Contains distributions of Ping times, by country and day/hour, using several bin sizes", br(),
                         "User's max ping is reported to provide a critical view of worst possible moment of service", br(),
                         "An interactive slider is provided in 'Ping > 250ms' to allow examining different thresholds", br(),
                         br(),
                         span(tags$b("Projects:"), style = "color:blue"), br(),
                         "This section includes ah hoc projects on key product and business topics", br(),
                         "Contents include analyses on churn, spender conversion, lifetime values (pending),", br(),
                         "and skin sale analysis (pending)", br(),
                         br(),          
                         span(tags$b("Ad Hoc Work:"), style = "color:green"), br(),
                         "Please see below for links to Ad Hoc work outside of dashboard", br(),
                         tags$a(href="https://shiny.superevilmegacorp.net/D1_Summary.html", "https://shiny.superevilmegacorp.net/D1_Summary.html"), br(),
                         tags$a(href="https://shiny.superevilmegacorp.net/Smurf_Analysis.html", "https://shiny.superevilmegacorp.net/Smurf_Analysis.html"), br(),
                         tags$a(href="https://shiny.superevilmegacorp.net/First_Spend.html", "https://shiny.superevilmegacorp.net/First_Spend.html"), br(),
                         tags$a(href="https://shiny.superevilmegacorp.net/First.Spend.DY.html", "https://shiny.superevilmegacorp.net/First.Spend.DY.html"), br(),
                         tags$a(href="https://shiny.superevilmegacorp.net/essence_economy.html", "https://shiny.superevilmegacorp.net/essence_economy.html"), br(),
                         tags$a(href="https://shiny.superevilmegacorp.net/H_and_S_by_Minutes_Played.html", "https://shiny.superevilmegacorp.net/H_and_S_by_Minutes_Played.html"), br(),                         
                         
                         br()
                         ))
            )  # end of row 
    ),  # end of tab    
    tabItem(tabName = "acquisition",
            fluidRow(
              column(width = 4,
                     box(width = NULL, plotOutput("g_engagement_status_all", height = "300px"),
                         title = "Installs by Engagement Status", solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, plotOutput("g_acquired_overall", height = '300px'),
                         title = "Installs by Status & Deployment",
                         solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, plotOutput("g_acquired_overall_percent", height = "300px"),
                         title = "Install % by Status & Deployment", solidHeader = T, status = "primary"))
            ),  # end of row
            fluidRow(
              column(width = 6,
                     box(width = NULL, plotOutput("g_acquired_country", height = "300px"),
                         title = "Installs by Country & Deployment", solidHeader = T, status = "primary")),
              column(width = 6, 
                     box(width = NULL, plotOutput("g_install_country", height = "300px"),
                         title = "Installs by Country", solidHeader = T, status = "primary"))
            ),  # end of row 
            fluidRow(width = 12,
                     box(width = 8,
                         checkboxGroupInput("check_box_group_acquisition", label = "Select Countries", 
                                      choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                               "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                               "South Korea" = "South Korea", "Total" = "Total",
                               "United States" = "United States", "Vietnam" = "Vietnam"), 
                               selected = c("China", "Russia", "United States"),
                           inline = TRUE), solidHeader = T, status = "primary"),
                     bsTooltip("check_box_group_acquisition", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                               "bottom", options = list(container = "body")),                    
                     box(width = 4,
                         checkboxGroupInput("check_box_group_2_acquisition", label = "Select Deployment Periods",
                                            choices = list("1.16" = "1.16", "1.17" = "1.17",
                                                           "1.18" = "1.18", "1.19" = "1.19",
                                                           "1.20" = "1.20", "1.21" = "1.21",
                                                           "1.22" = "1.22", "1.23" = "1.23"
                                                           ),
                                            selected = c("1.16", "1.17", "1.18", "1.19", "1.20", "1.21", "1.22", "1.23"),
                                            inline = TRUE), solidHeader = T, status = "primary"),
                         bsTooltip("check_box_group_2_acquisition", "Select one or more deployments to filter on.",
                                   "bottom", options = list(container = "body"))                  
                     ),   # end of row 
            fluidRow(
              column(width = 6,
                     box(width = NULL, plotOutput("g_spender_conversion_engagement_28", height = '300px'),
                         title = "Spender Conversion by Engagement Status (28 Days)",
                         solidHeader = T, status = "primary")
                     ),
              column(width = 6,
                     box(width = NULL, plotOutput("g_spender_conversion_engagement_unlimited", height = '300px'),
                         title = "Spender Conversion by Engagement Status (Unlimited)",
                         solidHeader = T, status = "primary"))
            ),  # end of row 
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_engagment_28_acquired", height = "300px"),
                         title = "28 day Engagement Status for Installed Users", 
                         solidHeader = T, status = "primary"))
            ),  # end of row 
            hr(),
            hr(),
            hr(), # spacing
            hr(),
            hr()     
    ),  # end of tab 
    tabItem(tabName = "activity",
            fluidRow(
              column(width = 4,
                     box(width = NULL, plotOutput("g_dau_country", height = "300px"),
                         title = "DAU (Trailing 30 days)", solidHeader = T, status = "primary")),
               column(width = 4,
                      box(width = NULL, plotOutput("g_dau_status_country", height = "300px"),
                          title = "DAU by User Status and Country", solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, #plotOutput("", height = "300px"),
                         title = "blank",
                         solidHeader = T, status = "primary"))
            ), # end of row 
            fluidRow(
              column(width = 2,
                     box(width = NULL,
                         selectInput(inputId = "select_input_activity", label = "Select a Country",
                                     choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                 "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                 "South Korea" = "South Korea", "United States" = "United States",
                                                 "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                     selected = c("China")), solidHeader = T, status = "primary")),
              column(width = 7,
                     box(width = NULL, 
                     checkboxGroupInput("check_box_group_activity", label = "Select Countries", 
                                        choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                       "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                       "South Korea" = "South Korea", "Total" = "Total",
                                                       "United States" = "United States", "Vietnam" = "Vietnam"), 
                                        selected = c("China", "Russia", "United States"),
                                        inline = TRUE), solidHeader = T, status = "primary"),
                     bsTooltip("check_box_group_activity", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                               "bottom", options = list(container = "body"))                        
                     ),
                     box(width = 3,
                         checkboxGroupInput("check_box_group_2_activity", label = "Select Deployment Periods",
                                            choices = list("1.16" = "1.16", "1.17" = "1.17",
                                                           "1.18" = "1.18", "1.19" = "1.19",
                                                           "1.20" = "1.20", "1.21" = "1.21",
                                                           "1.22" = "1.22", "1.23" = "1.23"
                                            ),
                                            selected = c("1.16", "1.17", "1.18", "1.19", "1.20", "1.21", "1.22", "1.23"),
                                            inline = TRUE), solidHeader = T, status = "primary"),
                        bsTooltip("check_box_group_2_activity", "Select one or more deployments to filter on.",
                                  "bottom", options = list(container = "body"))                
            ),  # end of row 
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_mau_status_deployment"),
                         title = "Monthly Active Users by Engagement Status and Deployment",
                         solidHeader = T, status = "primary"))
            ),  # end of row 
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_dau_deployment_active_status"),
                         title = "DAU by Deployment Active Status",
                         solidHeader = T, status = "primary"))
            ),  # end of row
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_dau_deployment_retention_status"),
                         title = "DAU by Deployment Retention Status",
                         solidHeader = T, status = "primary"))
            ),  # end of row   
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_dau_acquired_deployment_data"),
                         title = "DAU by Acquired Deployment",
                         solidHeader = T, status = "primary"))
            ),  # end of row   
            fluidRow(
              column(width = 4,
                      box(width = NULL,
                          checkboxGroupInput("check_box_group_2_activity_a", label = "Select Deployment Periods",
                                             choices = list("Prior to 1.13" = "Prior to 1.13",
                                                            "1.13" = "1.13", "1.14" = "1.14",
                                                            "1.15" = "1.15", "1.16" = "1.16",
                                                            "1.17" = "1.17", "1.18" = "1.18", 
                                                            "1.19" = "1.19", "1.20" = "1.20", 
                                                            "1.21" = "1.21", "1.22" = "1.22",
                                                            "1.23" = "1.23"
                                             ),
                                             selected = c("Prior to 1.13", "1.13", "1.14", "1.15", "1.16", "1.17", "1.18", 
                                                          "1.19", "1.20", "1.21", "1.22", "1.23"),
                                             inline = TRUE), solidHeader = T, status = "primary")),
                          bsTooltip("check_box_group_2_activity_a", "Select one or more deployments to filter on.",
                                    "bottom", options = list(container = "body")),       
               column(width = 6,
                      box(width = NULL, 
                          checkboxGroupInput("check_box_group_2_activity_b", label = "Select Countries", 
                                             choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                            "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                            "South Korea" = "South Korea", "Total" = "Total",
                                                            "United States" = "United States", "Vietnam" = "Vietnam",
                                                            "Total" = "Total"), 
                                             selected = c("China", "Russia", "United States"),
                                             inline = TRUE), solidHeader = T, status = "primary"),
                      bsTooltip("check_box_group_2_activity_b", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                                "bottom", options = list(container = "body"))                        
               ),
              column(width = 2,
                     box(width = NULL, 
                         checkboxGroupInput("check_box_group_2_activity_c", label = "Select Countries", 
                                            choices = list('ios' = 'ios',
                                                           'android' = 'android',
                                                           "Total" = "Total"), 
                                            selected = c('ios', 'android'),
                                            inline = TRUE), solidHeader = T, status = "primary"),
                     bsTooltip("check_box_group_2_activity_c", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                               "bottom", options = list(container = "body"))                        
              )
            ),  # end of row             
            hr(),
            hr(),
            hr(), # spacing
            hr(),
            hr(),
            hr(),            
            hr()                 
        ),   # end of tab 
    tabItem(tabName = "engagement", 
            fluidRow(
              column(width = 4,
                     box(width = NULL, plotOutput("g_days_first_win", height = "300px"),
                         title = "Days until first win", solidHeader = T, status = "primary")),
              column(width = 8,
                     box(width = NULL, plotOutput("g_first_day_win_count", height = "300px"),
                         title = "First Day Win Percent", solidHeader = T, status = "primary"))
            ), # end of row 
            fluidRow(
              column(width = 2,
                     box(width = NULL,
                         selectInput(inputId = "select_input_engagement", label = "Select a Country",
                                     choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                 "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                 "South Korea" = "South Korea", "United States" = "United States",
                                                 "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                     selected = c("United States")), solidHeader = T, status = "primary")),
              column(width = 2),
              column(width = 8,
                     box(width = NULL,
                         checkboxGroupInput(inputId = "check_box_group_engagement", label = "Select Countries",
                                     choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                 "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                 "South Korea" = "South Korea", "United States" = "United States",
                                                 "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                     selected = c("United States", "China", "Russia", "Total"),
                                     inline = T), solidHeader = T, status = "primary")),
                        bsTooltip("check_box_group_engagement", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                                  "bottom", options = list(container = "body"))  
              ) # end of row 
            ),   # end of tab 
    tabItem(tabName = "monetization",
            fluidRow(
              column(width = 4,
                     box(width = NULL, plotOutput("g_deployment_revenue_net_revenue", height = "300px"),
                         title = "Revenue", solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, plotOutput("g_deployment_revenue_arppu", height = "300px"),
                         title = "ARPPU by deployment", solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, plotOutput("g_deployment_revenue_arpdau", height = "300px"),
                         title = "ARPDAU by deployment", solidHeader = T, status = "primary"))
            ),  # end of row
            fluidRow(
              column(width = 4,
                     box(width = NULL, plotOutput("g_deployment_revenue_spender_count", height = "300px"),
                         title = "Spenders by Country", solidHeader = T, status = "primary")
              ),
              column(width = 4,
                     box(width = NULL, plotOutput("g_days_first_spend", height = "300px"),  
                         title = "Days to first spend", solidHeader = T, status = "primary")
              ),
              column(width = 4,
                     box(width = NULL, plotOutput("g_days_first_spend_percent", height = "300px"),
                         title = "Days to first spend (percent)", solidHeader = T, status = "primary"))
            ),  # end of row 
            fluidRow(
                     box(width = 8,
                         checkboxGroupInput("check_box_group_monetization", label = "Select Countries",
                              choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                              "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                              "South Korea" = "South Korea", "United States" = "United States",
                              "Total" = "Total",  "Vietnam" = "Vietnam"), 
                              selected = c("China", "Russia", "United States"),
                              inline = TRUE), status = "primary"),
                     bsTooltip("check_box_group_monetization", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                               "bottom", options = list(container = "body")),                    
                     box(width = 4,
                         checkboxGroupInput("check_box_group_2_monetization", label = "Select deployment periods",
                                            choices = list("1.16" = "1.16", "1.17" = "1.17",
                                                           "1.18" = "1.18", "1.19" = "1.19",
                                                           "1.20" = "1.20", "1.21" = "1.21",
                                                           "1.22" = "1.22", "1.23" = "1.23"
                                            ),
                                            selected = c("1.16", "1.17", "1.18", "1.19", "1.20", "1.21", "1.22", "1.23"),
                                            inline = TRUE), status = "primary"),
                     bsTooltip("check_box_group_2_monetization", "Select one or more deployments to filter on.",
                               "bottom", options = list(container = "body"))                       
            ),   # end of row 
            fluidRow(
              column(width = 4,
                     box(width = NULL, plotOutput("g_dau_spender_percent", height = "300px"),
                         title = "DAU Spender Percent", solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, plotOutput("g_arppu_trailing30", height = "300px"),
                         title = "ARPPU trailing 30 days", solidHeader = T, status = "primary")),
              column(width = 4,
                     box(width = NULL, plotOutput("g_arpdau_trailing30", height = "300px"),
                         title = "ARPDAU trailing 30 days", solidHeader = T, status = "primary"))
            ),   # end of row 
            fluidRow(column(width = 12, 
                            box(width = NULL, plotOutput("g_spenders_active_status", height = "300px"),
                         title = "Spenders by active status", solidHeader = T, status = "primary"))
            ),   # end of row 
            fluidRow(column(width = 12, 
                            box(width = NULL, plotOutput("g_percent_ever_spent", height = "300px"),
                                title = "Percent of Active Users Who Ever Spent", solidHeader = T, status = "primary"))
            ),   # end of row             
            fluidRow(
              column(width = 2,
                     box(width = NULL,
                         selectInput(inputId = "select_input_monetization", label = "Select a Country",
                                     choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                 "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                 "South Korea" = "South Korea", "United States" = "United States",
                                                 "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                     selected = c("United States")), solidHeader = T, status = "primary")),
              bsTooltip("select_input_monetization", "Select a country to filter on.",
                        "bottom", options = list(container = "body"))    
            ),              
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_spender_percent", height = "300px"),
                         title = "Spender percent by acquistion period and spend period",
                         solidHeader = T, status = "primary"))
            ),   
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_days_first_spend_iap_percent", height = "900px"),
                         title = "First Spend IAP by Days Since Install & Country", solidHeader = T, status = "primary"))
            ),
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_days_first_spend_iap_2_percent", height = "900px"),
                         title = "First Spend IAP by Days Since Install & Deployment", solidHeader = T, status = "primary"))
            ),  # end of row               
            hr(),
            hr(),
            hr(), # spacing
            hr(),
            hr(),
            hr(),
            hr(),
            hr(),
            hr(),
            hr()
            ),   # end of tab 
    tabItem(tabName = "churn",
            fluidRow(
              column(width=6,
                     box(width=NULL, plotOutput("g_churned_users_churn_count", height = "300px"),
                         title="7 Day Churned User Count (7 day lag)", solidHeader = T, status = "primary")),
              column(width=6,
                     box(width=NULL, plotOutput("g_churned_users_churn_rate", height = "300px"),
                         title="7 Day Churn Rate  (7 day lag)", solidHeader = T, status = "primary"))              
            ), # end of row 
            fluidRow(
              column(width=6,
                     box(width=NULL, plotOutput("g_churned_users_avg_lifetime", height = "300px"),
                         title="Churned Users Average Lifetime  (7 day lag)", solidHeader = T, status = "primary")),
              column(width=6,
                     box(width=NULL, plotOutput("g_churned_users_lifetime_weeks", height = "300px"),
                         title="Churned Users by Lifetime Weeks (7 day lag)", solidHeader = T, status = "primary"))              
            ), # end of row 
            fluidRow(            
            column(width = 2,
                   box(width = NULL,
                       selectInput(inputId = "select_input_churn", label = "Select a Country",
                                   choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                               "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                               "South Korea" = "South Korea", "United States" = "United States",
                                               "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                   selected = c("China")), solidHeader = T, status = "primary")), 
              column(width=8,  
                     box(width=NULL,
                         checkboxGroupInput("checkbox_churn", label = "Select Countries", 
                                            choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                           "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                           "South Korea" = "South Korea", "Total" = "Total",
                                                           "United States" = "United States", "Vietnam" = "Vietnam"), 
                                            selected = c("China", "Russia", "United States"),
                                            inline = TRUE), solidHeader = T, status = "primary")),
                        bsTooltip("checkbox_churn", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires",
                                  "bottom", options = list(container = "body")),
            column(width = 2,
                   box(width = NULL,
                       selectInput(inputId = "select_input_churn_2", label = "Select a Country",
                                   choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                               "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                               "South Korea" = "South Korea", "United States" = "United States",
                                               "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                   selected = c("China")), solidHeader = T, status = "primary"))        
            ), # end of row 
            fluidRow(
              column(width = 12,
                     box(width = NULL, height = "75px",
                         title = "Compare LTD Engagement Status Churn Rates Between Countires", solidHeader = T, status = "primary",
                         "Use 'Select a Country' on the upper right to control 'Chart A' and on the upper left to control 'Chart B'.", 
                         "The selector on the upper left controls the charts on the upper portion of the page. ", br()
                     ))
            ),  # end of row
            fluidRow(
              column(width=6,
                     box(width=NULL, plotOutput("g_churn_by_ltd_engagement_status", height = "300px"),
                         title="Churned Users by LTD Engagement Status ('Chart A')", solidHeader = T, status = "primary")),
              column(width=6,
                     box(width=NULL, plotOutput("g_churn_by_ltd_engagement_status_2", height = "300px"),
                         title="Churned Users by LTD Engagement Status ('Chart B')", solidHeader = T, status = "primary"))              
            ), # end of row   
            fluidRow(
              column(width=6,
                     box(width=NULL, plotOutput("g_weekly_churn_rate", height = "300px"),
                         title="Active2000 Weekly Churn Rate", solidHeader = T, status = "primary")),
              column(width=6,
                     box(width=NULL, plotOutput("g_monthly_churn_rate", height = "300px"),
                         title="Active2000 Monthly Churn Rate", solidHeader = T, status = "primary"))              
            ), # end of row              
            fluidRow(            
              column(width = 4,
                     box(width = NULL,            
                         selectInput(inputId = "churn_data_sets", label = "Choose a dataset:", 
                                     choices = c("7 Day Churned Rate & Count",
                                                 "Churned Users Average Lifetime",
                                                 "Churned Users by Lifetime Weeks"              
                                     )),
                         downloadButton('download_churn_data', 'Download'), solidHeader = T, status = "primary")),
              column(width=8,
                     box(width=NULL, #plotOutput("___TBD___", height = "300px"),
                         title="blank", solidHeader = T, status = "primary"))  
            ), 
            hr(),
            hr(),
            hr(), # spacing
            hr()
    ), #end of tab      
    tabItem(tabName = "retention_and_reactivation",
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_active_retention"),
                        title = "Active Retention", solidHeader = T, status = "primary"))
            ),  # end of row 
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_acquired_retention"),
                         title = "Acquired Retention", solidHeader = T, status = "primary"))
            ),  # end of row 
            fluidRow(
              box(width = 3,
                     selectInput(inputId = "select_input_retention_and_reactivation", label = "Select a Country",
                                 choices = c("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                             "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                             "South Korea" = "South Korea", "United States" = "United States",
                                             "Total" = "Total",  "Vietnam" = "Vietnam"), 
                                 selected = c("China")), solidHeader = T, status = "primary"),
              box(width = 4,
                  checkboxGroupInput("check_box_group_retention_and_reactivation", label = "Select Deployment Periods",
                                     choices = list("1.16" = "1.16", "1.17" = "1.17",
                                                    "1.18" = "1.18", "1.19" = "1.19",
                                                    "1.20" = "1.20", "1.21" = "1.21",
                                                    "1.22" = "1.22", "1.23" = "1.23"
                                     ),
                                     selected = c("1.16", "1.17", "1.18", "1.19", "1.20", "1.21", "1.22", "1.23"),
                                     inline = TRUE), solidHeader = T, status = "primary"),
              bsTooltip("check_box_group_retention_and_reactivation", "Select one or more deployments to filter on.",
                        "bottom", options = list(container = "body"))              
            ),    # end of row 
            fluidRow(
              column(width=6,
                     box(width=NULL, plotOutput("g_reactivated_users", height = "300px"),
                         title="Reactivated Users", solidHeader = T, status = "primary")),
              column(width=6,
                     box(width=NULL, plotOutput("g_weekly_reactivation_rate", height = "300px"),
                         title="Active2000 Weekly Reactivation Rate (of lapsed 8-14 days)", solidHeader = T, status = "primary"))              
            ), # end of row      
            fluidRow(
              column(width=6,
                     box(width=NULL, plotOutput("g_weekly_reactivation_percent", height = "300px"),
                         title="Active2000 Weekly Reactivation Percent (of WAU)", solidHeader = T, status = "primary")),
              column(width=6,
                     box(width=NULL, plotOutput("__TBD__", height = "300px"),
                         title="Empty", solidHeader = T, status = "primary"))              
            ), # end of row      
            hr(),
            hr(),
            hr(),  # white space
            hr(),
            hr(),
            hr(),
            hr(),
            hr()
    ), # end of tab 
    tabItem(tabName = "dau_stats",
        mainPanel(
          tabsetPanel(
            tabPanel("Cards", plotOutput("g_dau_avg_cards")),
            tabPanel("Essence", plotOutput("g_dau_avg_essence")),
            tabPanel("Glory", plotOutput("g_dau_avg_glory")),
            tabPanel("Ice", plotOutput("g_dau_avg_ice")),
            tabPanel("Buff", plotOutput("g_dau_avg_buff")),
            tabPanel("Tokens", plotOutput("g_dau_avg_tokens"))
          )
        )
        ),   # end of tab
    tabItem(tabName = "levels",
            mainPanel(
              tabsetPanel(
                tabPanel("Game Minutes",
                         fluidRow(
                           column(width = 10, plotOutput("g_level_minutes_game")),
                           column(width = 2,
                                  checkboxInput("check_box_levels_1", "Discrete", TRUE),
                                  checkboxInput("check_box_levels_2", "Cumulative", FALSE))
                         )),
                tabPanel("Game Hours",
                         fluidRow(
                           column(width = 10, plotOutput(("g_level_hours_game"))),
                           column(width = 2,
                                  checkboxInput("check_box_levels_3", "Discrete", TRUE),
                                  checkboxInput("check_box_levels_4", "Cumulative", FALSE))
                         )),
                tabPanel("Actual Minutes",
                         fluidRow(
                           column(width = 10, plotOutput("g_level_minutes_actual")),
                           column(width = 2,
                                  checkboxInput("check_box_levels_5", "Discrete", TRUE),
                                  checkboxInput("check_box_levels_6", "Cumulative", FALSE))
                         )),
                tabPanel("Actual Hours",
                         fluidRow(
                           column(width = 10, plotOutput("g_level_hours_actual")),
                           column(width = 2,
                                  checkboxInput("check_box_levels_7", "Discrete", TRUE),
                                  checkboxInput("check_box_levels_8", "Cumulative", FALSE))
                         ))

              ) # end of tabSetPanel
             )  # end of mainPanel
            ), # end of tab
    tabItem(tabName = "miscellaneous",
            mainPanel(
              tabsetPanel(
                tabPanel("Rank Counts", plotOutput("g_ascension_rank")),
                tabPanel("Rank Percentages", plotOutput("g_ascension_rank_percent")),
                tabPanel("Non-Redeemer Counts", plotOutput("g_dau_non_redeemers")),
                tabPanel("Non-Redeemer Percent", plotOutput("g_dau_non_redeemers_percent"))
            ))
            ),   # end of tab
    tabItem(tabName = "general_overview",
            fluidRow(width = 12,
                     box(width = NULL, plotOutput("g_ping7days_4buckets_all"),
                         solidHeader = T, status = "primary")),
            hr(),  # spacing
            hr()
    ),   # end of tab 
    tabItem(tabName = "all_pings_4_buckets",
            fluidRow(width =12, 
                     box(width = NULL, plotOutput("g_ping_4buckets_country"), 
                         title = "Ping by Date and Hour of Day",
                         solidHeader = T, status = "primary")
            ), # end of row 
            fluidRow(width = 3,
                     box(width = 3,
                         selectInput(inputId = "select_input_all_pings_4_buckets", label = "Select a Country", 
                                     choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                 'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                 'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                 'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                 'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                     selected = "United States"), status = "primary")
            ),  # end of row 
            fluidRow(
              box(width = 5, plotOutput("g_ping_4buckets_country_day1"), 
                  title = "Ping by Date",
                  solidHeader = T, status = "primary"),
              column(width = 1),
              box(width = 5, plotOutput("g_ping_4buckets_country_day2"), 
                  title = "Ping by Date",
                  solidHeader = T, status = "primary")
            ), # end of row 
            fluidRow(width = 12,
                     column(width = 3,
                            box(width = NULL,
                                selectInput(inputId = "select_input_all_pings_4_buckets_2", label = "Select a Country", 
                                            choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                        'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                        'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                        'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                        'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                            selected = "United States"), status = "primary")
                     ),
                     column(width = 3), # spacing between select inputs
                     column(width = 3,
                            box(width = NULL,
                                selectInput(inputId = "select_input_all_pings_4_buckets_3", label = "Select a Country", 
                                            choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                        'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                        'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                        'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                        'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                            selected = "United States"), status = "primary")
                     )
            ),  # end of row
            hr(),
            hr(),
            hr(),  # white space
            hr(),
            hr(),
            hr(),
            hr(),
            hr()
    ),   # end of tab
    tabItem(tabName = "max_ping_4_buckets",
            fluidRow(
              box(width = 5, plotOutput("g_ping_4buckets_country_day1_max"),
                  title = "Ping by Date",
                  solidHeader = T, status = "primary"),
              column(width = 1),
              box(width = 5, plotOutput("g_ping_4buckets_country_day2_max"),
                  title = "Ping by Date",
                  solidHeader = T, status = "primary")
            ), # end of row
            fluidRow(
              column(width = 3,
                     box(width = NULL, 
                         selectInput(inputId = "select_input_max_ping_4_buckets", label = "Select a Country", 
                                     choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                 'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                 'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                 'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                 'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                     selected = "United States"), status = "primary")
              ),
              column(width = 3),  # spacing between select inputs 
              column(width = 3,
                     box(width = NULL,
                         selectInput(inputId = "select_input_max_ping_4_buckets_2", label = "Select a Country", 
                                     choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                 'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                 'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                 'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                 'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                     selected = "United States"), status = "primary")
              )
            ),  # end of row
            hr(),
            hr(),
            hr(),  # white space
            hr(),
            hr(),
            hr(),
            hr(),
            hr()
    ),   # end of tab
    tabItem(tabName = "all_pings_21_buckets",
            fluidRow(
              box(width = 12, plotOutput("g_ping_21buckets_country"), 
                  title = "Ping by Date and Hour of Day",
                  solidHeader = T, status = "primary")
            ), # end of row 
            fluidRow(width = 12,
                     box(width = 3,
                         selectInput(inputId = "select_input_ping_summary_21_buckets", label = "Select a Country", 
                                     choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                 'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                 'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                 'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                 'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                     selected = "United States"), status = "primary")
            ), # end of row 
            fluidRow(
              box(width = 5, plotOutput("g_ping_21buckets_country_day1"), 
                  title = "Ping by Date",
                  solidHeader = T, status = "primary"),
              column(width = 1),
              box(width = 5, plotOutput("g_ping_21buckets_country_day2"), 
                  title = "Ping by Date",
                  solidHeader = T, status = "primary")
            ), # end of row 
            fluidRow(
              column(width = 3,
                     box(width = NULL,
                         selectInput(inputId = "select_input_ping_summary_21_buckets_2", label = "Select a Country", 
                                     choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                 'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                 'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                 'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                 'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                     selected = "United States"), status = "primary")
              ),
              column(width = 3),  # spacing between select inputs 
              column(width = 3,
                     box(width = NULL,
                         selectInput(inputId = "select_input_ping_summary_21_buckets_3", label = "Select a Country", 
                                     choices = c('China' = 'China', 'Brazil' = 'Brazil', 'Germany' = 'Germany',
                                                 'Indonesia' = 'Indonesia', 'Japan' = 'Japan', 'Philippines' = 'Philippines',
                                                 'Singapore' = 'Singapore', 'South Korea' = 'South Korea',
                                                 'Taiwan' = 'Taiwan', 'Thailand' = 'Thailand', 'United States' = 'United States',
                                                 'United Kingdom' = 'United Kingdom', 'Vietnam' = 'Vietnam'),
                                     selected = "United States"), status = "primary")
              )
            ),  # end of row
            hr(),
            hr(),
            hr(),  # white space
            hr(),
            hr(),
            hr(),
            hr(),
            hr()
    ),   # end of tab 
    tabItem(tabName = "pings_250ms",
            fluidRow(
              column(width = 12,
                     box(width = NULL, plotOutput("g_ping_interactive"),
                         title = "Percent of all pings > 250ms", solidHeader = T, status = "primary"))
            ), # end of row
            fluidRow(width = 12,
                     box(width = NULL,
                         checkboxGroupInput(inputId = "check_box_group_ping_250ms", label = "Countries", 
                                            choices = list('Brazil' = 'Brazil', 'China' = 'China', 'Germany' = 'Germany',
                                                           'Indonesia' = 'Indonesia', 'Japan' = 'Japan',
                                                           'Philippines' = 'Philippines', 'Singapore' = 'Singapore',
                                                           'South Korea' = 'South Korea', 'Taiwan' = 'Taiwan',
                                                           'Thailand' = 'Thailand', 'United Kingdom' = 'United Kingdom' ,
                                                           'United States' = 'United States', 'Vietnam' = 'Vietnam'), 
                                            selected = c("China", "Japan", "United States"),
                                            inline = TRUE), status = "primary")
            ), # end of row 
            fluidRow(
              box(
                sliderInput(inputId = "sliderping", label = "Count of pings > 250ms", min = 0,
                            max = 1000, value = 1, step = 1), status = "primary")
            )  # end of row 
    ),  # end of tab
    tabItem(tabName = "lifetime_value",
            fluidRow(
              column(width = 12, 
                     box(width = NULL, plotOutput("g_ltv_7_day_moving_avg"),
                         title = "LTV by Country (Since 6/1)", solidHeader = T, status = "primary"))
            ), # end of row                
            fluidRow(
               column(width = 12,                      
                     box(width = NULL,
                         checkboxGroupInput(inputId = "check_box_group_ltv", label = "Countries", 
                                            choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                           "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                           "South Korea" = "South Korea", 
                                                           "United States" = "United States", "Vietnam" = "Vietnam"), 
                                            selected = c("China", "Japan", "United States"),
                                            inline = TRUE), status = "primary"))
            ), # end of row 
            fluidRow(
               column(width = 12,                       
                     box(width = NULL, plotOutput("g_multi_level_ltv"),
                         title = "LTV by Deployment, Country & OS (Since 6/1)", solidHeader = T, status = "primary"))
            ), # end of row            
            fluidRow(width = 12,
                     box(width = 6,
                         checkboxGroupInput("check_box_group_multi_ltv_1", label = "Select Countries", 
                                            choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                           "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                           "South Korea" = "South Korea", "Total" = "Total",
                                                           "United States" = "United States", "Vietnam" = "Vietnam"), 
                                            selected = c("China", "Russia", "United States"),
                                            inline = TRUE), solidHeader = T, status = "primary"),
                     bsTooltip("check_box_group_multi_ltv_1", "Select one or more countries to filter on. To avoid double counting, select either Total or individual countires.",
                               "bottom", options = list(container = "body")),                    
                     box(width = 3,
                         checkboxGroupInput("check_box_group_multi_ltv_2", label = "Select Deployment Periods",
                                            choices = list("1.16" = "1.16", "1.17" = "1.17",
                                                           "1.18" = "1.18", "1.19" = "1.19",
                                                           "1.20" = "1.20", "1.21" = "1.21",
                                                           "1.22" = "1.22", "1.23" = "1.23"
                                            ),
                                            selected = c("1.16", "1.17", "1.18", "1.19", "1.20", "1.21", "1.22", "1.23"),
                                            inline = TRUE), solidHeader = T, status = "primary"),
                     bsTooltip("check_box_group_multi_ltv_2", "Select one or more deployments to filter on.",
                               "bottom", options = list(container = "body")),
                     box(width = 3,
                         checkboxGroupInput("check_box_group_multi_ltv_3", label = "Select Deployment Periods",
                                            choices = list("ios" = "ios", 
                                                           "android" = "android"
                                            ),
                                            selected = c("ios", "android"),
                                            inline = TRUE), solidHeader = T, status = "primary"),                     
                     bsTooltip("check_box_group_multi_ltv_3", "Select one or more deployments to filter on.",
                               "bottom", options = list(container = "body"))                  
            ),   # end of row    
            fluidRow(
              column(width = 12, 
                     box(width = NULL, 
                       title = 'Compare LTVs Between Countires', solidHeader = T, status = "primary",
                       "Use 'Select a Country' below each chart for countries, control both of the charts at the same time with ",
                       "the two selectors above: 'Select Deployment Periods' and 'Select Deployment Periods'. ", br()
                     ))
            ), # end of row               
            fluidRow(
              column(width = 6, 
                     box(width = NULL, plotOutput("g_multi_level_ltv_1"),
                         title = "LTV by Country, Deployment and OS (Since 6/1)", solidHeader = T, status = "primary")),
              column(width = 6, 
                     box(width = NULL, plotOutput("g_multi_level_ltv_2"),
                         title = "LTV by Country, Deployment and OS (Since 6/1)", solidHeader = T, status = "primary"))
            ), # end of row        
            fluidRow(width = 12,
                     box(width = 6,
                         selectInput(inputId = "select_input_multi_ltv_1a", label = "Select a Country",
                                     choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                    "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                    "South Korea" = "South Korea", "Total" = "Total",
                                                    "United States" = "United States", "Vietnam" = "Vietnam"), 
                                     selected = c("China")), solidHeader = T, status = "primary"),
                     box(width = 6,
                         selectInput(inputId = "select_input_multi_ltv_1b", label = "Select a Country",
                                     choices = list("China" = "China", "Indonesia" = "Indonesia", "Japan" = "Japan",
                                                    "Malaysia" = "Malaysia", "Other" = "Other", "Russia" = "Russia",
                                                    "South Korea" = "South Korea", "Total" = "Total",
                                                    "United States" = "United States", "Vietnam" = "Vietnam"), 
                                     selected = c("China")), solidHeader = T, status = "primary")
            ),
            hr(),  # spacing
            hr(), 
            hr(), 
            hr(),             
            hr()
    )   # end of tab     
  )  # end of tabItems 
)  # end of dashBoardBody 

##=============================================
## Compile Dashboard Page
##=============================================
dashboardPage(
  dashboardHeader(title = "SEMC"),
  sidebar,
  body
)