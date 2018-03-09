## Dominic Mullen
## 7/7/2016 

library(shinydashboard)
library(ggplot2)
#library(ggiraph)
#library(plotly)
library(data.table)
library(RPostgreSQL)
library(plyr)
library(dplyr)  # change data table and ddplyr / data table to dtplyr 
library(ggfortify) 
library(shinyBS)  # comment out if loading to server 
library(scales)


shinyServer(
  function(input, output, session){
     source("ascensionData.R")
     source("acquisitionData.R")
     source("activityData.R")
     source("churnData.R")
     source("engagementData.R")
     source("helpers.R")
     source("monetizationData.R")
     source("pingData.R")
     source("reactivationData.R")
     source("retentionData.R")
     source("lifetime_valueData.R")


  
##==============================================================================================
##  Acquisition Plots
##==============================================================================================  

    
##============================================  
## Engagement status all users - pie chart  (g_engagement_status_all)
## Acquistion
##============================================
  output$g_engagement_status_all <- renderPlot({  
    g <- ggplot(engagement_status_all, 
                aes(x = "",
                    y = sum,
                    fill = status_f))
    g <- g + geom_bar(stat = "identity") + 
      coord_polar("y",
                  start = 0) + 
      labs(x = "",
           y = "") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom") + 
      scale_y_continuous(labels = si_notation) 

    print(g)
  })
  
  addPopover(session, "g_engagement_status_all", "Data Definition", 
             content = paste0("Installed users grouped by engagement status. ", 
                              "Engagement status is based on their total minutes played in the ",
                              "28 day deployment period they installed during. ",
                              "Time period is March 30, 2016 to present."), trigger = 'hover')      
    
##============================================  
## Overall Acquired Users (g_acquired_overall & g_ )
## Acquistion  
##============================================ 
  acquired_overall_data <- reactive({
    data <- acquired_overall[deployment %in% input$check_box_group_2_acquisition]
    return(data)
  })
  
  labels_acquired_overall <- reactive({
    labels <- acquired_overall[deployment %in% input$check_box_group_2_acquisition]$engagement_status_28
    labels <- as.vector(labels)
    labels <- si_notation(labels)
    return(labels)
  })

  label_positions_acquired_overall <- reactive({
    positions <- acquired_overall[deployment %in% input$check_box_group_2_acquisition]$label_position
    positions <- as.vector(positions)
    return(positions)
  })
  
  output$g_acquired_overall <- renderPlot({
    g <- ggplot(acquired_overall_data(),
                aes(x = deployment,
                    y = engagement_status_28,
                    fill = status_f,
                    order = status_f))
    g <- g + geom_bar(stat = "identity") +
      labs(x = "Deployment",
           y = "Total Acquired Users") +
      theme(legend.position = "bottom", 
            legend.title = element_blank()) +
      scale_y_continuous(labels = si_notation) +
      geom_text(aes(label = labels_acquired_overall(),
                    y = label_positions_acquired_overall(),
                    size = 3,
                    # hjust = 0.5,
                    # vjust = 3,
                    position =     "stack"))
    
    print(g)
  })  
  
  # output$g_acquired_overall <- renderPlot({
  #   g <- ggplot(acquired_overall,
  #               aes(x = deployment,
  #                   y = engagement_status_28,
  #                   fill = status_f,
  #                   order = status_f))
  #   g <- g + geom_bar(stat = "identity") + 
  #     labs(x = "Deployment",
  #          y = "Total Acquired Users") + 
  #     theme(legend.position = "bottom",
  #           legend.title = element_blank()) + 
  #     scale_y_continuous(labels = si_notation) + 
  #     geom_text(data = acquired_overall, 
  #               aes(x = deployment, 
  #                   y = pos,
  #                   label = paste0(si_notation(engagement_status_28))),
  #                   check_overlap = TRUE
  #                 )      
  #   print(g) 
  # })
  
  addPopover(session, "g_acquired_overall", "Data Definition", 
             content = paste0("Installs grouped by engagement status and the deployment they installed during. ",
                              "Engagement status is based on their total minutes played in the ",
                              "28 day deployment period they installed during. ",
                              "Time period is March 30, 2016 to present. "), trigger = 'hover')  
  
  labels_acquired_overall_2 <- reactive({
    labels <- acquired_overall[deployment %in% input$check_box_group_2_acquisition]$engagement_status_28
    labels <- as.vector(labels)
    labels <- si_notation(labels)
    return(labels)
  })
  
  label_positions_acquired_overall_2 <- reactive({
    positions <- acquired_overall[deployment %in% input$check_box_group_2_acquisition]$label_position_pos
    positions <- as.vector(positions)
    return(positions)
  })  
  
  output$g_acquired_overall_percent <- renderPlot({
    g <- ggplot(acquired_overall_data(),
                aes(x = deployment,
                    y = engagement_status_28_percent, 
                    fill = status_f,
                    order = status_f
                ))
    g <- g + geom_bar(stat = "identity") +
      labs(x = "Deployment",
           y = "Total Acquired Users Percent") +
      theme(legend.position = "bottom",
            legend.title = element_blank()) +
      scale_y_continuous(labels = percent_notation_large) + 
    geom_text(aes(label = labels_acquired_overall_2(),
                  y = label_positions_acquired_overall_2(),
                  size = 3,
                  # hjust = 0.5,
                  # vjust = 3,
                  position = "stack"))

    print(g)
  })
  
  # output$g_acquired_overall_percent <- renderPlot({
  #   g <- ggplot(acquired_overall,
  #               aes(x = deployment,
  #                   y = engagement_status_28_percent,
  #                   fill = status_f,
  #                   order = status_f
  #                   ))
  #   g <- g + geom_bar(stat = "identity") +
  #     labs(x = "Deployment",
  #          y = "Total Acquired Users Percent") +
  #     theme(legend.position = "bottom",
  #           legend.title = element_blank()) +
  #     scale_y_continuous(labels = percent_notation_large) +
  #     geom_text(data = acquired_overall,
  #               aes(x = deployment,
  #                   y = pos_percent,
  #                   label = paste0(engagement_status_28_percent, "%"),
  #                   check_overlap = TRUE
  #                  ))
  #   print(g)
  # })

##============================================  
## Acquired Users by Country (g_acquired_country)
## Acquistion  
##============================================  
  acquired_country_data <- reactive({
    data <- acquired_country[country %in% input$check_box_group_acquisition]
    return(data)
  })
  
  # labels_acquired_country <- reactive({
  #   labels <- acquired_country[country %in% input$check_box_group_acquisition]$engagement_status_28
  #   labels <- as.vector(labels)
  #   labels <- si_notation(labels)
  #   return(labels)
  # })
  # 
  # label_positions_acquired_country <- reactive({
  #   positions <- acquired_country[country %in% input$check_box_group_acquisition]$engagement_status_28
  #   positions <- as.vector(positions)
  #   return(positions)
  # })
  
  output$g_acquired_country <- renderPlot({
    g <- ggplot(acquired_country_data(),
                aes(x = country,
                    y = engagement_status_28,
                    fill = country
                    )) +
      geom_bar(stat="identity") + #, position = "dodge"
      facet_grid(. ~ status_f,
                 switch = 'x') +
      labs(x = "Status",
           y= "") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom",
            axis.text.x = element_text(angle = 45,
                                       hjust = 1)) +
      scale_y_continuous(labels = si_notation) #+
      # geom_text(aes(label = labels_acquired_country(),
      #               #y = label_positions_acquired_country(),
      #               #x = interaction(status_f, country),
      #               size = 3,
      #               position = "dodge" 
      #               # hjust = 0.5,
      #               # vjust = 3
      #               ))

    print(g)
  })
  
  addPopover(session, "g_acquired_country", "Data Definition", 
             content = paste0("Installed users grouped by couuntry and engagement status. ", 
                              "Engagement status is based on their total minutes played in the ",
                              "28 day deployment period they installed during. ",
                              "Installs are cumulative. Time period is March 30, 2016 to present. "
                              ), trigger = 'hover')
    
##============================================  
## Installs by Country plot (g_install_country)
## Acquistion
##============================================  
  
  install_country_data <- reactive({
    data <- install_country[country %in% input$check_box_group_acquisition & 
                            deployment %in% input$check_box_group_2_acquisition]
    return(data)
  })
  
  output$g_install_country <- renderPlot({
    g <- ggplot(install_country_data(),
                aes(x = deployment,
                    y = installs,
                    fill = country))
    g <- g + geom_bar(stat = "identity",
                      position = "dodge")+ 
      labs(x = "Deployment", 
           y = "Installs") + 
      theme(legend.title = element_blank(), 
            legend.position = "bottom") + 
      scale_y_continuous(labels = si_notation)

    print(g)
  })
 
  addPopover(session, "g_install_country", "Data Definition", 
             content = paste0("Installed users grouped by couuntry and the deployment they were acquired during. "
                              ), trigger = 'hover')

##============================================  
## Spender Conversion by Engagement Status (g_spender_conversion_engagement_28)
## Previous 28 day time frame 
## Acquistion
##============================================  
  spender_conversion_engagement_28_data <- reactive({
    data <- spender_conversion_engagement_28[country %in% input$check_box_group_acquisition &
                                             deployment %in% input$check_box_group_2_acquisition]
    return(data)
  })
  
  output$g_spender_conversion_engagement_28 <- renderPlot({
    g <- ggplot(spender_conversion_engagement_28_data(),
                aes(x = deployment,
                    y = spender_conversion, 
                    fill = country)) + 
      geom_bar(stat="identity",
               position = "dodge") + 
      facet_grid(. ~ engagement_status_total_f,
                 switch = 'x') +    
      labs(x = "",
           y = "Spender Conversion") + 
      theme(legend.position = "bottom",
            legend.title = element_blank()) + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 column
      scale_y_continuous(labels = percent_notation_large)
    
    print(g)
  })    
  
  addPopover(session, "g_spender_conversion_engagement_28", "Data Definition", 
             content = paste0("Percent of installs that converted to spenders within the 28 day deployment period they installed during. ",
                              "Users are grouped by engagement status, deployment period, and country. ",
                              "Engagement status is based on their total minutes played in the ",
                              "28 daydeployment period they installed during."), trigger = 'hover')   
  
##============================================  
## Spender Conversion by Engagement Status (g_spender_conversion_engagement_unlimited)
## Unlimited time frame
## Acquistion
##============================================  
  spender_conversion_engagement_unlimited_data <- reactive({
    data <- spender_conversion_engagement_unlimited[country %in% input$check_box_group_acquisition &
                                                      deployment %in% input$check_box_group_2_acquisition]
    return(data)
  })
  
  output$g_spender_conversion_engagement_unlimited <- renderPlot({
    g <- ggplot(spender_conversion_engagement_unlimited_data(),
                aes(x = deployment,
                    y = spender_conversion, 
                    fill = country)) + 
      geom_bar(stat="identity",
               position = "dodge") + 
      facet_grid(. ~ engagement_status_total_f,
                 switch = 'x') +  #new variable (from BODdata) in correct order  
      labs(x = "",
           y = "Spender Conversion") + 
      theme(legend.position = "bottom",
            legend.title = element_blank()) + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 column
      scale_y_continuous(labels = percent_notation_large)
    
    print(g)
  })
  
  addPopover(session, "g_spender_conversion_engagement_unlimited", "Data Definition", 
             content = paste0("Percent of installs that converted to spenders within the 28 day deployment period they installed during. ",
                              "Users are grouped by engagement status, deployment period, and country. ",
                              "Engagement status is based on their total minutes played since install. ",
                              "(eg 'unlimited' time)."), trigger = 'hover')    
  
##============================================
## 28 day engagement status for acquired users  (g_engagment_28_acquired)
## Acquistion
##============================================
  engagement_28_acquisition_data <- reactive({
    data <- engagement_28_acquisition[country %in% input$check_box_group_acquisition & 
                                      deployment %in% input$check_box_group_2_acquisition]
    return(data)
  })    
  
  output$g_engagment_28_acquired <- renderPlot({
    g <- ggplot(engagement_28_acquisition_data(),
                aes(x = status_f,
                    y = engagement_status_28_percent,
                    fill = country))
    g <- g +  geom_bar(stat = "identity",
                       position = "dodge") +
    facet_grid(. ~ deployment,
               switch = "x") + 
    theme(axis.text.x = element_text(angle = 45,
                                     hjust = 1),
          legend.title = element_blank()) + 
    labs(x = "Deployment", 
         y = "Engagment Percent") + 
    scale_y_continuous(labels = percent_notation_large)
    
    print(g)
  })
  
  addPopover(session, "g_engagment_28_acquired", "Data Definition", 
             content = paste0("Percent of Installed users by their engagement status, deployment and country. ",
                              "Percentages are calculated out of total installs in a period by country. ",
                              "Time period is March 30, 2016 to present. "), trigger = 'hover')  

##==============================================================================================
##  Activity Plots
##==============================================================================================  

##============================================
## DAU by country (g_dau_country)
## Activity 
##============================================
  dau_country_data <- reactive({
    data <- dau_country[country %in% input$check_box_group_activity]
    return(data)
  })
  
  output$g_dau_country <- renderPlot({
    g <- ggplot(dau_country_data(),
                aes(x = event_date,
                    y = user_count,
                    group = country))
    g <- g + geom_line(aes(colour = country)) + 
      labs(x = "",
           y = "User Count") + 
      theme(legend.position = "bottom",
            legend.title = element_blank()) + 
      scale_y_continuous(labels = si_notation)
    
    print(g)
  })  
  
  addPopover(session, "g_dau_country", "Data Definition", 
             content = paste0("Daily Active Users grouped by country for the trailing 30 days. "
                              ), trigger = 'hover')    
  
##============================================
## DAU by Status and country (g_dau__status_country)
## Activity 
##============================================  
  dau_status_country_data <- reactive({
    data <- dau_status_country[country == input$select_input_activity]
    return(data)
  })
  
  output$g_dau_status_country <- renderPlot({
  g <- ggplot(dau_status_country_data(), 
              aes(x = event_date, 
                  y = user_count,
                  fill = user_status_f))
  g <- g + geom_bar(stat = "identity") + 
    labs(x = "", 
         y = "User count") + 
    ggtitle(input$select_input_activity) +   #reactive title 
    theme(legend.title = element_blank(),
          legend.position = "bottom") + 
    scale_y_continuous(labels = si_notation)
  
  print(g)
  })
  
  addPopover(session, "g_dau_status_country", "Data Definition", 
             content = paste0("DAU grouped by user status. ", 
                              "User Status is based on whether the user was 'new', 'existing' or legacy' on install. ",
                              "'Existing' and 'Legacy' users uninstalled and re-installed, or were forced to a new IDFA. ",
                              "Legacy refers to users that installed pre 1/15/16. "
                              ), trigger = 'hover')    
  
##============================================
## MAU ltd 28 day status by deployment and country (g_mau_status_deployment)
## Activity
##============================================  
  mau_status_deployment_data <- reactive({
    data <- mau_status_deployment[country %in% input$check_box_group_activity & 
                                  deployment %in% input$check_box_group_2_activity]
    return(data)
  })
  
  output$g_mau_status_deployment <- renderPlot({
  g <- ggplot(mau_status_deployment_data(), 
              aes(x = status_f,
                  y = engagement_status_28,
                  fill = country)) 
  g <- g + geom_bar(stat = "identity",
                    position = "dodge") + 
    facet_grid(. ~ deployment, 
               switch = 'x') + 
    labs(x = "Deployment", 
         y = "User Count") + 
    theme(legend.title = element_blank(),
          legend.position = "bottom",
          axis.text.x = element_text(angle = 45,
                                     hjust = 1)) + 
    guides(fill=guide_legend(nrow=1)) +  #make legend 1 column
    scale_y_continuous(labels = si_notation)
  
  print(g)
  })
  
  addPopover(session, "g_mau_status_deployment", "Data Definition", 
             content = paste0("Monthly Active Users (based on the 28 day periods) grouped by country, deployment and egagement status. ",
                              "Engagement status is determined by minuted played life to date by the end of the 28 day deployment period. ",  
                              "Time period is March 30, 2016 to present. "), trigger = 'hover')    

  ##============================================
  ## User Deployment Active & Retention Statuses (g_dau_deployment_active_status & g_dau_deployment_retention_status )
  ## Activity
  ##============================================  
  
  dau_deployment_active_status_data <- reactive({
    data <- dau_deployment_active_status[deployment %in% input$check_box_group_2_activity]
    return(data)
  })  
  
  output$g_dau_deployment_active_status <- renderPlot({
    g <- ggplot(dau_deployment_active_status_data(), 
                aes(x = event_date,
                    y = user_count,
                    fill = deployment_active_status)) + 
      geom_bar(stat = "identity") + 
      facet_grid(. ~ deployment,
                 switch = 'x',
                 scales = "free_x") +
      labs(x = "Event Date & Deployment", 
           y = "User Count by Deployment Active Status") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom",
            axis.text.x = element_text(angle = 45,
                                       hjust = 1)) + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 column
      scale_y_continuous(labels = si_notation)
    
    print(g)
  })  

  dau_deployment_retention_status_data <- reactive({
    data <- dau_deployment_retention_status[deployment %in% input$check_box_group_2_activity]
    return(data)
  })    
  
  output$g_dau_deployment_retention_status <- renderPlot({
    g <- ggplot(dau_deployment_retention_status_data(), 
                aes(x = event_date,
                    y = user_count,
                    fill = deployment_retention_status)) + 
      geom_bar(stat = "identity") + 
      facet_grid(. ~ deployment,
                 switch = 'x',
                 scales = "free_x") +
      labs(x = "Event Date & Deployment", 
           y = "User Count by Deployment Retention Status") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom",
            axis.text.x = element_text(angle = 45,
                                       hjust = 1)) + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 column
      scale_y_continuous(labels = si_notation)
    
    print(g)
  })    
  
##============================================
## DAU by Acquired Deployment (g_dau_acquired_deployment_data)
## Activity 
##============================================  
  
  dau_acquired_deployment_data <- reactive({
    data <- dau_acquired_deployment[acquired_deployment %in% input$check_box_group_2_activity_a &
                                    country %in% input$check_box_group_2_activity_b &
                                    os_name %in% input$check_box_group_2_activity_c]
    return(data)
  })    
  
  output$g_dau_acquired_deployment_data <- renderPlot({
    g <- ggplot(dau_acquired_deployment_data(), 
                aes(x = event_date,
                    y = user_count,
                    fill = acquired_deployment)) + 
      geom_bar(stat = "identity") + 
      facet_grid(. ~ country,
                 switch = 'x',
                 scales = "free_x") +
      labs(x = "Event Date", 
           y = "DAU by Acquired Deployment") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom",
            axis.text.x = element_text(angle = 45,
                                       hjust = 1)) + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 column
      scale_y_continuous(labels = si_notation) + 
      scale_x_date(breaks = date_breaks("months"),
                   labels = date_format("%b"))
    
    print(g)
  })      
  
  
##==============================================================================================
##  Engagement Plots
##==============================================================================================    
  
##================================
## Days until first win (g_days_first_win)
## Engagement 
##================================
  days_first_win_data <- reactive({
    data <- days_first_win[country == input$select_input_engagement]
    return(data)
  })
  
  output$g_days_first_win <- renderPlot({
  g <- ggplot(days_first_win_data(), 
              aes(x = days_until_first_win,
                  y = win_percent))
  g <- g + geom_line(colour = "blue") + 
    labs(x = "Days until first win",
         y = "") + 
    guides(fill = FALSE) + 
    scale_y_continuous(labels = percent_notation_large) +
    ggtitle(input$select_input_engagement) + 
    geom_line(data = days_first_win_data(),
            aes(x = days_until_first_win, y = cumulative_win_percent)) + 
    guides(fill = FALSE) + 
    annotate("text", label = "Win Percent", x = 60, y = 5) + 
    annotate("text", label = "Cumulative Win Percent", x = 60, y = 60)
  
  print(g)
  
}) 


##================================
## First Day win count (g_first_day_win_count)
## Engagement 
##================================ 
  first_day_win_count_data <- reactive({
    data <- first_day_win_count[country %in% input$check_box_group_engagement]
    return(data)
  })
  
  output$g_first_day_win_count <- renderPlot({
  g <- ggplot(first_day_win_count_data(), 
              aes(x = first_login_date,
                  y = first_day_win_rate,
                  group = country))
  g <- g + geom_line(aes(colour = country)) + 
    labs(x = "",
         y = "Win rate") + 
    theme(legend.title = element_blank()) + 
    scale_y_continuous(labels = percent_notation_large)
  
  print(g)    
  }) 

  
##==============================================================================================
##  Monetization Plots
##==============================================================================================    
   
##============================================  
## Net Revenue by Country (g_deployment_revenue_net_revenue)
## Monetization
##============================================ 
  deployment_revenue_data1 <- reactive({
     data <- deployment_revenue[country %in% input$check_box_group_monetization &
                                deployment %in% input$check_box_group_2_monetization]
   })
  
   output$g_deployment_revenue_net_revenue <- renderPlot({
    g <- ggplot(deployment_revenue_data1(),
                aes(x = deployment,
                    y = net_revenue,
                    group = country))
    g <- g + geom_line(aes(colour = country)) + 
      labs(x = "Deployment",
           y = "") + 
      theme(legend.position = "bottom", 
            legend.title = element_blank()) + 
      scale_y_continuous(labels = dollar_si_notation)
    print(g)
    
  })
   

##============================================  
## Spender Count by Country (g_deployment_revenue_spender_count)
## Monetization
##============================================ 
   deployment_revenue_data2 <- reactive({
     data <- deployment_revenue[country %in% input$check_box_group_monetization & 
                                deployment %in% input$check_box_group_2_monetization]
   })
   
   output$g_deployment_revenue_spender_count <- renderPlot({
     g <- ggplot(deployment_revenue_data2(),
                 aes(x = deployment,
                     y = spender_count,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "Deployment", y = "") + 
        theme(legend.position = "bottom", 
             legend.title = element_blank(),
             axis.text.x = element_text(size = 8)) +
       scale_y_continuous(labels = si_notation)
     print(g)
     
   })
   
##============================================  
## ARPDAU and ARPPU plots (g_deployment_revenue_arppu, g_deployment_revenue_arpdau)
## Monetization
##============================================ 
   deployment_revenue_data3 <- reactive({
     data <- deployment_revenue[country %in% input$check_box_group_monetization &
                                deployment %in% input$check_box_group_2_monetization]
     return(data)
   })
   
   output$g_deployment_revenue_arppu <- renderPlot({
     g <- ggplot(deployment_revenue_data3(),
                 aes(x = deployment,
                     y = net_arppu,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "Deployment",
            y = "") + 
       theme(legend.position = "bottom",
             legend.title = element_blank(),
             axis.text.x = element_text(size = 10)) + 
       scale_y_continuous(labels = dollar_notation)
     print(g)
     
   })
   
   output$g_deployment_revenue_arpdau <- renderPlot({
     g <- ggplot(deployment_revenue_data3(),
                 aes(x = deployment,
                     y = net_arpdau,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "Deployment",
            y = "") + 
       theme(legend.position = "bottom",
             legend.title = element_blank()) + 
       scale_y_continuous(labels = dollar_notation)
     print(g)
   
  })
   
##============================================ 
## Spender Percent by acquisition period and spent period (g_spender_percent)
## Monetization
##============================================ 
   spender_percent_data <- reactive({
     data <- spender_percent[country == input$select_input_monetization & 
                               acquisition_deployment %in% input$check_box_group_2_monetization]
     return(data)
   })
   
   output$g_spender_percent <- renderPlot({
   g <- ggplot(spender_percent_data(),
               aes(x = engagement_status_total_f,
                   y = spender_percent,
                   fill = engagement_status_total_f))
   g <- g +  geom_bar(stat = "identity",
                      position = "dodge") + 
        facet_grid(. ~ acquisition_deployment + spend_deployment,
                   switch = "x") + 
     labs(x = "",
          y = "Spender Percent") + 
     guides(fill = FALSE) + 
     theme(axis.text.x = element_text(angle = 90,
                                      hjust = 1)) +  
     scale_y_continuous(labels = percent_notation_large)
   
   print(g)
   
   })
   
   addPopover(session, "g_spender_percent", "Data Definition", 
              content = paste0("Spender Percent by acquisition period and LTD engagement status. ", 
                               "Engagement status is based on their total minutes played by the ",
                               "end of each 28 day deployment period. On the X axis, the first level ",
                               "is engagement status, the second is acquisition deployment and the ",
                               "thrid level is the deployment period they spent in. ", 
                               "Time period is March 30, 2016 to present."), trigger = 'hover')     
   
   
##============================================
## DAU Spender Percent by Country (g_dau_spender_percent)
## Monetization
##============================================
   dau_spender_percent_data <- reactive({
     data <- dau_spender_percent[country %in% input$check_box_group_monetization]
     return(data)
   })
   
   output$g_dau_spender_percent <- renderPlot({
     g <- ggplot(dau_spender_percent_data(), 
                 aes(x = event_date, 
                     y = spender_percent,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "", 
            y = "DAU Spender Percent") + 
       theme(axis.text.x = element_text(size = 10),
             axis.text.y = element_text(size = 10),
             legend.text = element_text(size = 10),
             legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
     })
   
   
##============================================
## Days to first spend (by Percent) (g_days_first_spend_percent)
## Monetization
##============================================
   days_first_spend_percent_data <- reactive({
     data <- days_first_spend_percent[country %in% input$check_box_group_monetization]
     return(data)
   })
   
   output$g_days_first_spend_percent <- renderPlot({
     g <- ggplot(days_first_spend_percent_data(),
                 aes(x = days_to_first_spend,
                     y = percent,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "Days", 
            y = "Percent") + 
       theme(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 10),
             legend.text = element_text(size = 12),
             legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = percent_notation_small)

     print(g)
     
   })
   
##============================================
## Days to first spend (g_days_first_spend)
## Monetization
##============================================
   days_first_spend_data <- reactive({
     data <- days_first_spend[country %in% input$check_box_group_monetization]
     return(data)
   })
   
   output$g_days_first_spend <- renderPlot({
     g <- ggplot(days_first_spend_data(),
                 aes(x = days_to_first_spend,
                     y = user_count,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "Days", 
            y = "User count") + 
       theme(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 10),
             legend.text = element_text(size = 12),
             legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = si_notation)
     
     print(g)
     
   })
   
   
##============================================
## Days to first spend (g_days_first_spend_iap_percent)
## Monetization
##============================================
   # days_first_spend_iap_percent_data <- reactive({
   #   data <- days_first_spend_iap_percent[country %in% input$check_box_group_monetization]
   #   return(data)
   # })

   output$g_days_first_spend_iap_percent <- renderPlot({
     g <- ggplot(days_first_spend_iap_percent,
                 aes(x = days_to_first_spend,
                     y = percent,
                     fill = productid))
     g <- g + geom_bar(stat = "identity") +
       facet_wrap(~ country,
                  ncol = 3,
                  scales = "free") +
       labs(x = "Days",
            y = "User count") +
       theme(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 10),
             legend.text = element_text(size = 12),
             legend.title = element_blank(),
             legend.position = "bottom") +
       scale_y_continuous(labels = percent_notation_small)

     print(g)
   })
   
   days_first_spend_iap_2_percent
   
   output$g_days_first_spend_iap_2_percent <- renderPlot({
     g <- ggplot(days_first_spend_iap_2_percent,
                 aes(x = days_to_first_spend,
                     y = percent,
                     fill = productid))
     g <- g + geom_bar(stat = "identity") +
       facet_wrap(~ deployment,
                  ncol = 3,
                  scales = "free") +
       labs(x = "Days",
            y = "User count") +
       theme(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 10),
             legend.text = element_text(size = 12),
             legend.title = element_blank(),
             legend.position = "bottom") +
       scale_y_continuous(labels = percent_notation_small)
     
     print(g)
   })   
   
   ##============================================
   ## Percent of Active Users Who Ever Spent  (g_
   ## Monetization
   ##============================================   
   
   percent_ever_spent_data <- reactive({
     data <- percent_ever_spent[country %in% input$check_box_group_monetization]
     return(data)
   })
   
   output$g_percent_ever_spent <- renderPlot({
     g <- ggplot(percent_ever_spent_data(),
                 aes(x = lifetime_28_day_engagement_status_f,
                     y = ltd_spender_percent,
                     fill = country))
     g <- g + geom_bar(stat = "identity",
                       position = "dodge") +
       facet_grid(. ~ deployment,
                  switch = "x") +
       labs(x = "",
            y = "Spender count") +
       theme(axis.text.x = element_text(angle = 45,
                                        hjust = 1),
             legend.title = element_blank(),
             legend.position = "bottom") +
       guides(fill=guide_legend(nrow=1)) +
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)   
   })      
   
##============================================
## ARPPU / ARPDAU by trailing 30 days (g_arppu_trailing30)
##                                    (g_arpdau_trailing30)
## Monetization
##============================================
   arppu_arpdau_trailing30_data <- reactive({
     data <- arppu_arpdau_trailing30[country %in% input$check_box_group_monetization]
     return(data)
   })
   
   output$g_arppu_trailing30 <- renderPlot({
     g <- ggplot(arppu_arpdau_trailing30_data(),
                 aes(x = event_date,
                     y = arppu,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "",
            y = "") + 
       theme(legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = dollar_notation)
     
     print(g)
     
   })
   
   output$g_arpdau_trailing30 <- renderPlot({
     g <- ggplot(arppu_arpdau_trailing30_data(), 
                 aes(x = event_date,
                     y = arpdau,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "",
            y = "") + 
       theme(legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = dollar_notation)
     
     print(g)
     
   })
   
   
##============================================
## SPENDERS by Active Status (g_spenders_active_status)
## Monetization
##============================================   
   spenders_active_status_data <- reactive({
     data <- spenders_active_status[country %in% input$check_box_group_monetization &
                                    deployment %in% input$check_box_group_2_monetization]
     return(data)
   })
   
   output$g_spenders_active_status <- renderPlot({
   g <- ggplot(spenders_active_status_data(),
               aes(x = lifetime_28_day_engagement_status_f,
                   y = spender_count,
                   fill = country))
   g <- g + geom_bar(stat = "identity",
                     position = "dodge") + 
     facet_grid(. ~ deployment,
                switch = "x") +
     labs(x = "",
          y = "Spender count") + 
     theme(axis.text.x = element_text(angle = 45,
                                      hjust = 1),
           legend.title = element_blank(),
           legend.position = "bottom") + 
     guides(fill=guide_legend(nrow=1)) + 
     scale_y_continuous(labels = si_notation)
   
   print(g)
   
   })
   

 ##==============================================================================================
 ##  Churn Plots
 ##==============================================================================================

 ##============================================
 ## 7 Day Churned User Rate (g_churned_users_churn_rate) and Churn Count (g_churned_users_churn_count)
 ## Avg lifetime of churned users (g_churned_users_avg_lifetime) 
 ## Churn
 ##============================================
   
   churned_users_data <- reactive({
     data <- churned_users[country %in% input$checkbox_churn]
     return(data)
   }) 
   
   output$g_churned_users_churn_count <- renderPlot({
     g <- ggplot(churned_users_data(), 
                 aes(x = event_date,
                     y = churned_user_count,
                     group = country)) +
       geom_line(aes(colour = country)) + 
       labs(x = "Date", y ="Churn Rate") + 
       theme(legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = si_notation)
     print(g) 
   })  
   
  output$g_churned_users_churn_rate <- renderPlot({
     g <- ggplot(churned_users_data(),
                 aes(x = event_date,
                     y = churn_rate,
                     group = country)) +
       geom_line(aes(colour = country)) + 
       labs(x = "Date", y ="Churn Rate") + 
       theme(legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(labels = percent_notation_large) 
     print(g) 
   })         
  
##============================================  
## Churn by Average Lifetime Length (Days)
## Churn 
##============================================   
  
  churned_users_avg_lifetime_data <- reactive({
    data <- churned_users_avg_lifetime[country %in% input$checkbox_churn]
    return(data)  
  })   
   
  output$g_churned_users_avg_lifetime <- renderPlot({   
     g <- ggplot(churned_users_avg_lifetime_data(),
                 aes(x = event_date,
                     y = avg_lifetime_days,
                     group = country)) +
       geom_line(aes(colour = country)) + 
       labs(x = "Date", y ="Lifetime (Weeks)") + 
       theme(legend.title = element_blank(),
             legend.position = "bottom")
     print(g) 
   })   
  
##============================================  
## Churn by Lifetime Weeks (distribution)
## Churn 
##============================================    
  
  churned_users_lifetime_weeks_data <- reactive({
    data <- churned_users_lifetime_weeks[country == input$select_input_churn]
    return(data)
  })
  
  output$g_churned_users_lifetime_weeks <- renderPlot({    
    g <- ggplot(churned_users_lifetime_weeks_data(),
                aes(x = event_date,
                    y = churned_user_count,
                    fill = weeks_since_install_buckets_f)) +   
      geom_bar(stat = "identity") + 
      labs(x = "Date", y ="Lifetime Week Buckets") + 
      ggtitle(input$select_input_churn) +   #reactive title       
      theme(legend.title = element_blank(),
            legend.position = "bottom") + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 row
      scale_y_continuous(labels = si_notation)
    print(g) 
  }) 
  
##============================================  
## Churn by LTD Engagement Status
## Churn 
##============================================ 
  
  
  churn_by_ltd_engagement_status_data <- reactive({
    data <- churn_by_ltd_engagement_status[country == input$select_input_churn]
    return(data)  
  })   
  
  output$g_churn_by_ltd_engagement_status <- renderPlot({
  g <- ggplot(churn_by_ltd_engagement_status_data(),
              aes(x = event_date,
                  y = churn_rate,
                  group = lifetime_engagement_status_f)) +   
    geom_line(stat = "identity", aes(colour = lifetime_engagement_status_f)) + 
    labs(x = "Date", y ="Churn Rate") + 
    ggtitle(input$select_input_churn) +   #reactive title 
    theme(legend.title = element_blank(),
          legend.position = "bottom") + 
    guides(fill=guide_legend(nrow=1)) +  #make legend 1 row
    scale_y_continuous(label = percent_notation_large, limits = c(1,20))
  print(g) 
  }) 

  churn_by_ltd_engagement_status_data_2 <- reactive({
    data <- churn_by_ltd_engagement_status[country == input$select_input_churn_2]
    return(data)  
  })     
  
  output$g_churn_by_ltd_engagement_status_2 <- renderPlot({
    g <- ggplot(churn_by_ltd_engagement_status_data_2(),
                aes(x = event_date,
                    y = churn_rate,
                    group = lifetime_engagement_status_f)) +   
      geom_line(stat = "identity", aes(colour = lifetime_engagement_status_f)) + 
      labs(x = "Date", y ="Churn Rate") + 
      ggtitle(input$select_input_churn_2) +   #reactive title 
      theme(legend.title = element_blank(),
            legend.position = "bottom") + 
      guides(fill=guide_legend(nrow=1)) +  #make legend 1 row
      scale_y_continuous(label = percent_notation_large, limits = c(1,20))
    print(g) 
  })   
  
  
##============================================
## BizOps Active2000 Weekly Churn Rate (g_weekly_churn_rate) 
## Churn
##============================================
  
  output$g_weekly_churn_rate <- renderPlot({   
    g <- ggplot(weekly_churn_rate,
                aes(x = event_date,
                    y = weekly_churn_rate)) +
      geom_line(colour = 'purple') + 
      labs(x = "Date", y ="Churn Rate") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom") + 
      scale_y_continuous(label = percent_notation_large, limits = c(1,100))
    print(g) 
  })    
  
  addPopover(session, "g_weekly_churn_rate", "Data Definition", 
             content = paste0("The percent of Active2000 users that played 8-14 days ago, . ", 
                              "but did not play 1-7 days ago, as a percent of those that were ",
                              "played 8-14 days ago."), trigger = 'hover')    
  
##============================================
## BizOps Active2000 Monthly Churn Rate (g_weekly_churn_rate) 
## Churn
##============================================
  
  output$g_monthly_churn_rate <- renderPlot({   
    g <- ggplot(monthly_churn_rate,
                aes(x = event_date,
                    y = monthly_churn_rate)) +
      geom_line(colour = 'purple') + 
      labs(x = "Date", y ="Churn Rate") + 
      theme(legend.title = element_blank(),
            legend.position = "bottom") +
      scale_y_continuous(label = percent_notation_large, limits = c(1,100))
    print(g) 
  })    
  
  addPopover(session, "g_monthly_churn_rate", "Data Definition", 
             content = paste0("The percent of Active2000 users that played 29-56 days ago, . ", 
                              "but did not play 1-28 days ago, as a percent of those that were ",
                              "played 29-56 days ago."), trigger = 'hover')  
  
##============================================  
## Data Download
## Churn 
##============================================ 
  
  churn_datasetInput <- reactive({
    switch(input$churn_data_sets,
           "7 Day Churned Rate & Count" = churned_users_data(),
           "Churned Users Average Lifetime" = churned_users_avg_lifetime_data(),
           "Churned Users by Lifetime Weeks" = churned_users_lifetime_weeks_data())
  })  
  
  output$download_churn_data <- downloadHandler(
    filename = function() { paste(input$dataset, '.csv', sep='') },
    content = function(file) {
      write.csv(churn_datasetInput(), file)
    }
  )
  

##==============================================================================================
##  Retention & Reactivation Plots
##==============================================================================================  

##============================================  
## Active user retention data by 28 day engagement status (g_active_retention)
## Retention & Reactivation
##============================================ 
   active_retention_data <- reactive({
     data <- active_retention[country == input$select_input_retention_and_reactivation & 
                                active_deployment %in% input$check_box_group_retention_and_reactivation]
     return(data)
   })
   
   output$g_active_retention <- renderPlot({
     g <- ggplot(active_retention_data(),
                 aes(x = lifetime_engagement_status_f,
                     y = retention_rate,
                     fill = lifetime_engagement_status_f))
     g <- g + geom_bar(stat = "identity") +
       facet_grid(. ~  active_deployment + retained_deployment,
                  switch = "x") +
       labs(x = "Active Period", y = "Retention Rate") +
       scale_y_continuous(labels = percent_notation_large) + 
       theme(axis.text.x = element_blank(),
             legend.title = element_blank())
     
     print(g) 
   })
   
   addPopover(session, "g_active_retention", "Data Definition", 
              content = paste0("Active User Retention by deployment period and LTD engagement status. ", 
                               "Engagement status is based on their total minutes played by the ",
                               "end of each 28 day deployment period. On the X axis, the first level ",
                               "the active deployment period and the second is the future deployment ",
                               "periods the users were retained in. ", 
                               "Time period is March 30, 2016 to present."), trigger = 'hover')     
   
   
##============================================  
## Acquired user retention data by 28 day engagement status (g_acquired_retention)
## Retention & Reactivation
##============================================       
   acquired_retention_data <- reactive({
     data <- acquired_retention[country == input$select_input_retention_and_reactivation & 
                                  acquired_deployment %in% input$check_box_group_retention_and_reactivation]
     return(data)
   })
   
   output$g_acquired_retention <- renderPlot({
   g <- ggplot(acquired_retention_data(), 
               aes(x = engagement_status_28_f, 
                   y = retention_rate,
                   fill = engagement_status_28_f))
   g <- g + geom_bar(stat = "identity") + 
     facet_grid(. ~ acquired_deployment + retained_deployment,
                switch = "x") + 
     labs(x = "Acquisition Period",
          y ="Retention Rate") + 
     theme(axis.text.x = element_blank(),
           legend.title = element_blank()) + 
     scale_y_continuous(label = percent_notation_large)
   
   print(g)
})   
   
   
   addPopover(session, "g_acquired_retention", "Data Definition", 
              content = paste0("Acquired User Retention by deployment period and LTD engagement status. ", 
                               "Engagement status is based on their total minutes played by the ",
                               "end of each 28 day deployment period. On the X axis, the first level ",
                               "the acquired deployment period and the second is the future deployment ",
                               "periods the users were retained in. ", 
                               "Time period is March 30, 2016 to present."), trigger = 'hover')     
   
   
##=================================   
## Reactivated Users by country (g_reactivated_users) 
## Retention & Reactivation
##=================================
   reactivated_users_data <- reactive({
     data <- reactivated_users[country == input$select_input_retention_and_reactivation]
     return(data)
   })
   
   output$g_reactivated_users <- renderPlot({
   g <- ggplot(reactivated_users_data(), 
               aes(x = event_date,
                   y = reactivated_user_count,
                   group = weeks_since_active_buckets_f))
   g + geom_line(aes(colour = weeks_since_active_buckets_f)) + 
     labs(x = "",
          y = "User count") + 
     ggtitle(input$selectinputreactivation) + 
     theme(legend.title = element_blank(),
           legend.position = "bottom") + 
     scale_y_continuous(labels = si_notation)
   })
   

 ##=================================   
 ## BizOps Active2000 Weekly Reactivation Rate (g_weekly_reactivation_rate) 
 ## Retention & Reactivation
 ##=================================
   
   output$g_weekly_reactivation_rate <- renderPlot({
     g <- ggplot(weekly_reactivation_rate, 
                 aes(x = event_date,
                     y = weekly_reactivation_rate))
     g + geom_line(colour = "purple") + 
       labs(x = "Event Date",
            y = "User count") + 
       #ggtitle(input$selectinputreactivation) + 
       theme(legend.title = element_blank(),
             legend.position = "bottom") + 
     scale_y_continuous(label = percent_notation_large, limits = c(1,100))
   })     
   
   addPopover(session, "g_weekly_reactivation_rate", "Data Definition", 
              content = paste0("The percent of recently lapsed Active2000 users that have been reactivated. ", 
                               "These are users that played 35 to 15 days ago, but did not play ",
                               "14 to 8 days ago, and then reactived in the last 7 days, ",
                               "as a percent of the lapsed 14 to 8 days segment. "), trigger = 'hover')    
   
   ##=================================   
   ## BizOps Active2000 Weekly Reactivation Percent (g_weekly_reactivation_percent) 
   ## Retention & Reactivation
   ##=================================
   
   output$g_weekly_reactivation_percent <- renderPlot({
     g <- ggplot(wau_reactivated_percent, 
                 aes(x = event_date,
                     y = wau_reactivated_percent))
     g + geom_line(colour = "purple") + 
       labs(x = "Event Date",
            y = "User count") + 
       #ggtitle(input$selectinputreactivation) + 
       theme(legend.title = element_blank(),
             legend.position = "bottom") + 
       scale_y_continuous(label = percent_notation_large, limits = c(1,100))
   })     
   
   addPopover(session, "g_weekly_reactivation_percent", "Data Definition", 
              content = paste0("The percent of WAU that consist of recently reactivated Active2000 players. ", 
                               "These are users that played 35 to 15 days ago, but did not play ",
                               "14 to 8 days ago, and then reactived in the last 7 days, as a percent of WAU. "), trigger = 'hover')     
   
   
##==============================================================================================
##  Ascension Plots
##==============================================================================================  
   
##======================================
## Daily average cards (g_dau_avg_cards)
##=======================================
  output$g_dau_avg_cards <- renderPlot({
    g <- ggplot(dau_avg_cards,
                aes(x = event_date,
                    y = ascension_cards_per_dau))
    g <- g + geom_line() +
        labs(x = "", y = "Average Cards per DAU")
    
    print(g)
    
  })
  
##======================================
## Daily average essence (g_dau_avg_essence)
##=======================================
  output$g_dau_avg_essence <- renderPlot({
    g <- ggplot(dau_avg_essence,
           aes(x = event_date,
               y = ascension_essence_per_dau)) 
    g <- g + geom_line() +
        labs(x = "",
             y = "Average Essence per DAU")
    
    print(g)
    
  })
  
##======================================
## Daily average glory (g_dau_avg_glory)
##=======================================  
  output$g_dau_avg_glory <- renderPlot({
    g <- ggplot(dau_avg_glory,
           aes(x = event_date,
               y = ascension_glory_per_dau))
    g <- g + geom_line() +
        labs(x = "",
             y = "Average Glory per DAU")
    
    print(g)
    
  })
  
##======================================
## Daily average ice (g_dau_avg_ice)
##=======================================    
  output$g_dau_avg_ice <- renderPlot({
    g <- ggplot(dau_avg_ice,
                aes(x = event_date,
                    y = ascension_ice_per_dau))
    g <- g + geom_line() +
        labs(x = "",
             y = "Average Ice per DAU")
    
    print(g)
    
  })
  
##======================================
## Daily average buff (g_dau_avg_buff)
##=======================================   
  output$g_dau_avg_buff <- renderPlot({
    g <- ggplot(dau_avg_buff,
                aes(x = event_date,
                    y = ascension_buff_per_dau))
    g <- g + geom_line() +
        labs(x = "",
             y = "Average Buff per DAU")
    
    print(g)
    
  })

##======================================
## Daily average tokens (g_dau_avg_tokens)
##=======================================    
  output$g_dau_avg_tokens <- renderPlot({
    g <- ggplot(dau_avg_tokens,
            aes(x = event_date,
                y = ascension_tokens_per_dau))
    g <- g + geom_line(group = 1) +
          labs(x = "",
               y = "Ascension Tokens per DAU") 
      #scale_x_date(breaks = date_format("%W"), date_breaks("weeks"))
      # theme(axis.text.x = element_text(angle = 45,
      #                                  hjust = 1))
      
      print(g)
      
  })


##======================================
## Game minutes to ascension level (g_level_minute_game)
##======================================= 
  output$g_level_minutes_game <- renderPlot({
    g1 <- ggplot(level_minutes_game,
                 aes(x = next_ascension_rank,
                     y = avg_minutes_to_level)) +
      geom_line()
    g2 <- ggplot(level_minutes_game,
                 aes(x = next_ascension_rank,
                     y = cum_avg_minutes_to_level)) +
      geom_line()
    if(input$check_box_levels_1 == TRUE){
      print(g1)
    }
    if(input$check_box_levels_2 == TRUE){
      print(g2)
    }
    
  })
  
##======================================
## Game Hours to ascension level (g_level_hours_game)
##======================================= 
  output$g_level_hours_game <- renderPlot({
    g1 <- ggplot(level_hours_game,
                 aes(x = next_ascension_rank,
                     y = avg_hours_to_level)) +
      geom_line()
    g2 <- ggplot(level_hours_game,
                 aes(x = next_ascension_rank,
                     y = cum_avg_hours_to_level)) +
      geom_line()
    if(input$check_box_levels_3 == TRUE){
      print(g1)
    }
    if(input$check_box_levels_4 == TRUE){
      print(g2)
    }
    
  })

##======================================
## Actual minutes to ascension level (g_level_minutes_actual)
##======================================= 
  output$g_level_minutes_actual <- renderPlot({
    g1 <- ggplot(level_minutes_actual,
                 aes(x = next_ascension_rank,
                     y = avg_minutes_to_level)) +
      geom_line()
    g2 <- ggplot(level_minutes_actual,
                 aes(x = next_ascension_rank,
                     y = cum_avg_minutes_to_level)) +
      geom_line()
    if(input$check_box_levels_5 == TRUE){
      print(g1)
    }
    if(input$check_box_levels_6 == TRUE){
      print(g2)
    }
    
  })

##======================================
## Actual Hours to ascension level (g_level_hours_actual)
##======================================= 
  output$g_level_hours_actual <- renderPlot({
    g1 <- ggplot(level_hours_actual,
                 aes(x = next_ascension_rank,
                     y = avg_hours_to_level)) +
      geom_line()
    g2 <- ggplot(level_hours_actual,
                 aes(x = next_ascension_rank,
                     y = cum_avg_hours_to_level)) +
      geom_line()
    if(input$check_box_levels_7 == TRUE){
      print(g1)
    }
    if(input$check_box_levels_8 == TRUE){
      print(g2)
    }
    
  })

  
##======================================
## Players by Ascension Rank (g_ascension_rank)
##=======================================  
   output$g_ascension_rank <- renderPlot({
     g <- ggplot(ascension_rank,
            aes(x = ascension_rank,
                y = user_count))
     g <- g + geom_bar(stat = "identity") +
        labs(x = "Ascension Rank",
             y = "User Count") + 
        scale_y_continuous(labels = si_notation)
     
     print(g)
     
   })

##======================================
## Players by Ascension Rank Percent (g_ascension_rank_percent)
##=======================================  
   output$g_ascension_rank_percent <- renderPlot({
     g <- ggplot(ascension_rank,
                 aes(x = ascension_rank,
                     y = rank_percentage))
     g <- g + geom_bar(stat = "identity") +
          labs(x = "Ascension Rank", y = "Percentage") +
          scale_y_continuous(labels = percent_notation_small)
     
     print(g)
     
   })

##======================================
## Daily Chest non-redeemers (g_dau_non_redeemers)
##=======================================     
   output$g_dau_non_redeemers <- renderPlot({
   g <- ggplot(dau_non_redeemers,
              aes(x = event_date,
                  y = non_redeemer_percent))
   g <- g + geom_bar(stat="identity") +
     labs(x = "",
          y = "Percent") +
     scale_y_continuous(labels = percent_notation_large)
   
   print(g)
   
   })
   
##======================================
## Daily Chest non-redeemers (g_dau_non_redeemers_percent)
##=======================================        
   output$g_dau_non_redeemers_percent <- renderPlot({
     g <- ggplot(dau_non_redeemers,
                aes(x = event_date,
                    y = non_redeemers))
     g <- g + geom_bar(stat="identity") +
        labs(x = "",
             y = "User Count") + 
        scale_y_continuous(labels = si_notation)
     
     print(g)
     
   })


   
##==============================================================================================
##  Ping Plots
##==============================================================================================  
   
##==============================================================   
## Ping plots, 4 buckets, by country, for trailing 7 day period, hours not included
## (g_ping7days_4buckets_all),   
## Tab: General Overview
##==============================================================   
   
   output$g_ping7days_4buckets_all <- renderPlot({
     g <- ggplot(ping_4buckets_country_day,
                 aes(x = event_date,
                     y = percent,
                     fill = ping_buckets))
     g <- g + geom_bar(stat= "identity") +
       facet_grid(. ~ country,
                  switch = "x") +  # switch = 'x' puts grid label on bottom
       labs(x = "",
            y = "") + 
       theme(legend.title = element_blank(),
             axis.ticks.x = element_blank()) + 
       ggtitle("Percent of all Pings (trailing 7 days)") + 
       guides(fill=guide_legend(ncol=1)) +  #make legend 1 column
       scale_x_discrete(breaks = levels(ping_4buckets_country$event_date)[rep(F,1)]) +  # hides date labels (too crowded)
       scale_fill_manual(values = c("green", "yellow", "orange", "red")) + 
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
   })
   
   
##==============================================================
## Country specific ping graphs, 4 buckets (g_ping_4buckets_country) 
## Tab: All Pings: 4 Buckets
##============================================================== 
   
   ping_4buckets_country_data <- reactive({
     data <- ping_4buckets_country[country == input$select_input_all_pings_4_buckets]
   })   
   
   output$g_ping_4buckets_country <- renderPlot({
     g <- ggplot(ping_4buckets_country_data(),
                 aes(x = hod_gmt,
                     y = percent,
                     fill = ping_buckets))
     g <- g + geom_bar(stat= "identity") +
       facet_grid(. ~ event_date,
                  switch = "x") +  # switch = 'x' puts grid label on bottom
       scale_x_discrete(breaks = levels(ping_4buckets_country$hod_gmt)[c(T,rep(F,2))]) +  # custom x-axis labels
       labs(x = "",
            y = "") + 
       theme(legend.title = element_blank()) + 
       guides(fill=guide_legend(ncol=1)) + 
       ggtitle(input$select_input_all_pings_4_buckets) + 
       scale_fill_manual(values = c("green", "yellow", "orange", "red")) + 
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
     
   })
   
   
##==============================================================
## (By Day only) Country specific ping graphs, 4 buckets (g_ping_4buckets_country_day1)
##                                                       (g_ping_4buckets_country_day2)
## Tab: All Pings: 4 Buckets
##============================================================== 
   
   ping_4buckets_country_day_data2 <- reactive({
     data <- ping_4buckets_country_day[country == input$select_input_all_pings_4_buckets_2]
   })
   
   output$g_ping_4buckets_country_day1 <- renderPlot({
     g <- ggplot(ping_4buckets_country_day_data2(),
                 aes(x = event_date,
                     y = percent,
                     fill = ping_buckets)) 
     g <- g + geom_bar(stat = "identity",
                       position = "dodge") + 
       ggtitle(input$select_input_all_pings_4_buckets_2) + 
       labs(x = "",
            y = "Percent") + 
       scale_fill_manual(values = c("green", "yellow", "orange", "red")) + 
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
     
   })
   
   # Duplicate plot, reacts to different input 
   
   ping_4buckets_country_day_data3 <- reactive({
     data <- ping_4buckets_country_day[country == input$select_input_all_pings_4_buckets_3]
   })
   
   output$g_ping_4buckets_country_day2 <- renderPlot({
     g <- ggplot(ping_4buckets_country_day_data3(),
                 aes(x = event_date,
                     y = percent,
                     fill = ping_buckets)) 
     g <- g + geom_bar(stat = "identity",
                       position = "dodge") + 
       ggtitle(input$select_input_all_pings_4_buckets_3) + 
       labs(x = "", y = "Percent") + 
       scale_fill_manual(values = c("green", "yellow", "orange", "red")) +  
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
     
   })
   
   
##==============================================================
## (By Day only) Country specific ping graphs, 4 buckets (g_ping_4buckets_country_day1_max)
##                                                       (g_ping_4buckets_country_day2_max)
## For user's Max ping only 
## Tab: Max ping: 4 Buckets
##============================================================== 
   
   data_maxping_long_data2 <- reactive({
     data <- data_maxping_long[country == input$select_input_max_ping_4_buckets]
   })
   
   output$g_ping_4buckets_country_day1_max <- renderPlot({
     g <- ggplot(data_maxping_long_data2(),
                 aes(x = event_date,
                     y = user_percent,
                     fill = pingbucket)) 
     g <- g + geom_bar(stat = "identity") + 
       ggtitle(input$select_input_max_ping_4_buckets) + 
       labs(x = "",
            y = "Percent") + 
       scale_fill_manual(values = c("green", "yellow", "orange", "red")) + 
       theme(legend.title = element_blank()) + 
       theme(axis.text.x = element_text(angle = 45,
                                        hjust = 1)) +  
       scale_y_continuous(labels = percent_notation_small)
     
     print(g)
     
   })
   
   # Duplicate plot, reacts to different input 
   
   data_maxping_long_data3 <- reactive({
     data <- data_maxping_long[country == input$select_input_max_ping_4_buckets_2]
   })
   
   output$g_ping_4buckets_country_day2_max <- renderPlot({
     g <- ggplot(data_maxping_long_data3(),
                 aes(x = event_date,
                     y = user_percent,
                     fill = pingbucket)) 
     g <- g + geom_bar(stat = "identity") + 
       ggtitle(input$select_input_max_ping_4_buckets_2) + 
       labs(x = "",
            y = "Percent") + 
       scale_fill_manual(values = c("green", "yellow", "orange", "red")) + 
       theme(legend.title = element_blank()) + 
       theme(axis.text.x = element_text(angle = 45,
                                        hjust = 1)) + 
       scale_y_continuous(labels = percent_notation_small)
     
     print(g)
     
   })
   
   
##==============================================================
## Country specific ping graphs, 21 buckets (g_ping_21buckets_country) 
## Tab: Ping Summary: 21 Buckets
##============================================================== 
   
   ping_21buckets_country_data <- reactive({
     data <- ping_21buckets_country[country == input$select_input_ping_summary_21_buckets]
   })   
   
   output$g_ping_21buckets_country <- renderPlot({
     g <- ggplot(ping_21buckets_country_data(),
                 aes(x = hod_gmt,
                     y = percent,
                     fill = ping_buckets))
     g <- g + geom_bar(stat= "identity") +
       facet_grid(. ~ event_date,
                  switch = "x") +  # switch = 'x' puts grid label on bottom
       scale_x_discrete(breaks = levels(ping_21buckets_country$hod_gmt)[c(T,rep(F,2))]) +  # custom x-axis labels
       labs(x = "",
            y = "") + 
       theme(legend.title = element_blank()) + 
       guides(fill=guide_legend(ncol=1)) + 
       ggtitle(input$select_input_ping_summary_21_buckets) +   # reactive title 
       scale_fill_manual(values = c("forestgreen", "green3", "green2",
                                    "greenyellow", "yellow", "yellow1", "yellow2","gold1",	
                                    "darkgoldenrod1", "orange", "orange1" ,"orange2", "darkorange",
                                    "darkorange2","orangered1", "red", "red1" , "red2", "red3",
                                    "firebrick3", "red4")) + 
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
     
   })  
   
   
##==============================================================
## (By Day only) Country specific ping graphs, 21 buckets (g_ping_21buckets_country_day1)
##                                                       (g_ping_21buckets_country_day1)
## Tab: Ping Summary: 21 Buckets
##============================================================== 
   
   ping_21buckets_country_day_data2 <- reactive({
     data <- ping_21buckets_country_day[country == input$select_input_ping_summary_21_buckets_2]
   })
   
   output$g_ping_21buckets_country_day1 <- renderPlot({
     g <- ggplot(ping_21buckets_country_day_data2(),
                 aes(x = event_date,
                     y = percent,
                     fill = ping_buckets)) 
     g <- g + geom_bar(stat = "identity",
                       position = "dodge") + 
       ggtitle(input$select_input_ping_summary_21_buckets_2) + 
       labs(x = "", y = "Percent") + 
       theme(legend.title = element_blank()) + 
       guides(fill=guide_legend(ncol=1)) +
       scale_fill_manual(values = c("forestgreen", "green3", "green2",
                                    "greenyellow", "yellow", "yellow1", "yellow2","gold1",	
                                    "darkgoldenrod1", "orange", "orange1" ,"orange2", "darkorange",
                                    "darkorange2","orangered1", "red", "red1" , "red2", "red3",
                                    "firebrick3", "red4")) + 
       scale_y_continuous(labels = percent_notation_large)
     print(g)
     
   })
   
   # Duplicate plot, reacts to different input 
   
   ping_21buckets_country_day_data3 <- reactive({
     data <- ping_21buckets_country_day[country == input$select_input_ping_summary_21_buckets_3]
   })
   
   output$g_ping_21buckets_country_day2 <- renderPlot({
     g <- ggplot(ping_21buckets_country_day_data3(),
                 aes(x = event_date,
                     y = percent,
                     fill = ping_buckets)) 
     g <- g + geom_bar(stat = "identity",
                       position = "dodge") + 
       ggtitle(input$select_input_ping_summary_21_buckets_3) + 
       guides(fill=guide_legend(ncol=1)) +
       theme(legend.title = element_blank()) + 
       scale_fill_manual(values = c("forestgreen", "green3", "green2",
                                    "greenyellow", "yellow", "yellow1", "yellow2","gold1",	
                                    "darkgoldenrod1", "orange", "orange1" ,"orange2", "darkorange",
                                    "darkorange2","orangered1", "red", "red1" , "red2", "red3",
                                    "firebrick3", "red4")) + 
       scale_y_continuous(labels = percent_notation_large)
     
     print(g)
     
   })

   ##==============================================================
   ## Problematic Pings by country - user's maximum ping (g_ping_interactive)
   ## Percent of all pings > 250ms
   ## Tab: Interactive Ping Chart 
   ##============================================================== 
   
   maxping_data <- reactive({
     maxping[a_250plus >= input$sliderping, Oneplus := 1]
     maxping[a_250plus < input$sliderping, Oneplus := 0]
     k = 1
     data <- data.frame()
     for(j in input$check_box_group_ping_250ms){
       for(i in unique(maxping$event_date)){
         data[k,1] = j
         data[k,2] = i
         data[k,3] <- sum(maxping[country == j & event_date == i]$Oneplus)/dim(maxping[country == j & event_date == i])[1]
         k = k + 1 
       }
     }
     colnames(data) = c("country", "event_date", "percent")
     return(data)
   })
   
   output$g_ping_interactive <- renderPlot({
     g <- ggplot(maxping_data(),
                 aes(x = event_date,
                     y = percent,
                     fill = country)) + 
       geom_bar(stat = "identity",
                position = "dodge") + 
       labs(x = "",
            y = "Percent") + 
       theme(legend.title = element_blank(), 
             legend.position = "bottom") +
       guides(fill=guide_legend(nrow=1)) +  #make legend 1 row
       scale_y_continuous(labels = scales::percent)
     
     print(g) 
   })
   
 ##==============================================================================================
 ##  LTV Lifetime Value Plots
 ##==============================================================================================     
   
   ##==============================================================
   ## 7 Day Moving Avg LTV by Country (g_ltv_7_day_moving_avg) 
   ## LTV by country averaged across all daily cohorts, then with a 7 day moving avg on the overall avg
   ## Tab: Interactive Ping Chart 
   ##==============================================================    

   ltv_7_day_moving_avg_data <- reactive({
     data <- ltv_7_day_moving_avg[country %in% input$check_box_group_ltv] 
     return(data)
   })
   
   str(ltv_7_day_moving_avg)
   
   output$g_ltv_7_day_moving_avg <- renderPlot({
     g <- ggplot(ltv_7_day_moving_avg_data(),
                 aes(x = days_since_install,
                     y = moving_7_day_avg_cohort_ltv,
                     group = country))
     g <- g + geom_line(aes(colour = country)) + 
       labs(x = "",
            y = "Lifetime Value") + 
       theme(legend.position = "bottom",
             legend.title = element_blank()) + 
       scale_y_continuous(labels = dollar)
     
     print(g)
   })  
   
   addPopover(session, "g_ltv_7_day_moving_avg", "Data Definition", 
              content = paste0("7 Day moving average of country lifetime values. "
              ), trigger = 'hover')  
   
   ##==============================================================
   ## 7 Day Moving Avg LTV by Country, Deployment and OS Name (g_multi_level_ltv) 
   ##   NOTE: Adds os_name and deployment to the existing country grouping from above (eg g_ltv_7_day_moving_avg)
   ## LTV by country averaged across all daily cohorts, then with a 7 day moving avg on the overall avg
   ##==============================================================    
   
   multi_level_ltv_data <- reactive({
     data <- multi_level_ltv[country %in% input$check_box_group_multi_ltv_1 & 
                               deployment %in% input$check_box_group_multi_ltv_2 &
                             os_name %in% input$check_box_group_multi_ltv_3 ]
     return(data)
   })
   
   # ggplot(dat = melt(df, id.var="A"), aes(x=A, y=value)) + 
   #   geom_line(aes(colour=variable, group=variable)) + 
   #   geom_point(aes(colour=variable, shape=variable, group=variable), size=4)

   output$g_multi_level_ltv <- renderPlot({
     g <- ggplot(multi_level_ltv_data(),
                 aes(x = days_since_install,
                     y = moving_7_day_avg_ltv,
                     colour = interaction(country,
                                          #deployment,
                                           os_name
                                         ),
                     group = interaction(country,
                                         #deployment,
                                         os_name
                                         )
                 )) + 
       geom_line(aes(colour = interaction(country,
                                           #deployment,
                                           os_name
                       )
                     )
                 ) +
       # geom_point(aes(colour = os_name
       #                 #,shape = os_name
       #                 # ,group = interaction(#country,
       #                 #                     deployment,
       #                 #                     os_name)
       #                 ),
       #           size=4) +
       facet_grid(. ~ deployment,
                  switch = 'x',
                  labeller=label_both,
                  scales = "free_x") +
       labs(x = "",
            y = "Lifetime Value") + 
       theme(legend.position = "bottom",
             legend.title = element_blank()) + 
       scale_y_continuous(labels = dollar)
     
     print(g)
   })     
   
 
 ##==============================================================
 ## 7 Day Moving Avg LTV by Country, Deployment and OS Name (g_multi_level_ltv) 
 ## Side by Side comparison of LTV: allows countries to be be compared by deployment and OS 
 ## 
 ##==============================================================      
   
   multi_level_ltv_data_1 <- reactive({
     data <- multi_level_ltv[country == input$select_input_multi_ltv_1a & 
                               deployment %in% input$check_box_group_multi_ltv_2 &
                               os_name %in% input$check_box_group_multi_ltv_3 ]
     return(data)
   })   
   
   output$g_multi_level_ltv_1 <- renderPlot({
     g <- ggplot(multi_level_ltv_data_1(),
                 aes(x = days_since_install,
                     y = moving_7_day_avg_ltv,
                     colour = interaction(deployment,
                                          os_name
                     ),
                     group = interaction(deployment,
                                         os_name
                                         )
                 )) + 
       geom_line(aes(colour = interaction(deployment,
                                          os_name
                                          ),
                     #,shape = os_name
                     group = interaction(
                                          deployment,
                                          os_name)
                 )) +
       labs(x = "",
            y = "Lifetime Value") + 
       theme(legend.position = "bottom",
             legend.title = element_blank()) + 
       scale_y_continuous(labels = dollar)
     
     print(g)
   })     
   
   
   multi_level_ltv_data_2 <- reactive({
     data <- multi_level_ltv[country == input$select_input_multi_ltv_1b & 
                               deployment %in% input$check_box_group_multi_ltv_2 &
                               os_name %in% input$check_box_group_multi_ltv_3 ]
     return(data)
   })   
   
   output$g_multi_level_ltv_2 <- renderPlot({
     g <- ggplot(multi_level_ltv_data_2(),
                 aes(x = days_since_install,
                     y = moving_7_day_avg_ltv,
                     colour = interaction(deployment,
                                          os_name
                     ),
                     group = interaction(deployment,
                                         os_name
                     )
                 )) + 
       geom_line(aes(colour = interaction(deployment,
                                          os_name
       ),
       #,shape = os_name
       group = interaction(
         deployment,
         os_name)
       )) +
       labs(x = "",
            y = "Lifetime Value") + 
       theme(legend.position = "bottom",
             legend.title = element_blank()) + 
       scale_y_continuous(labels = dollar)
     
     print(g)
   })      
   
   ##==============================================================
   ## 7 Day Moving Avg LTV by Country, Deployment and OS Name (g_multi_level_ltv) 
   ## Side by Side comparison of LTV: allows countries to be be compared by deployment and OS 
   ## 
   ##==============================================================     
   
   #load chart 
   # g_skins_by_minutes_b <- ggplot(country_days_ltv, 
   #                                aes(x = days_since_install,
   #                                    y = cohort_ltv,
   #                                    color = country,
   #                                    group = spender_status
   #                                ))
   # #create chart 
   # g_skins_by_minutes_b + 
   #   geom_jitter(aes(size = user_count, 
   #                   color = country)) + 
   #   geom_smooth() + 
   #   facet_grid(. ~ country,
   #              switch = 'X') + 
   #   ggtitle("Skins Owned By Minutes Played") + 
   #   labs(x = "Skins Owned Count", y = "Minutes Played Count") +
   #   theme(legend.position="bottom") + 
   #   theme(axis.text.x = element_text(size = 10, angle = 00)) #
   # 
   
})  ## end of server function 
##==========================================================================================  


