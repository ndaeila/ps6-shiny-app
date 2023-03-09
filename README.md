# Documentation for Shiny App: Global Temperature Data
### This Shiny App allows you to explore the UAH lower troposphere dataset, which contains monthly temperature anomalies from different regions around the world.

https://ndaeila.shinyapps.io/ps6-shiny-app/

### Data
The dataset includes four columns:

**year**: the year in which the measurement was taken

**month**: the month in which the measurement was taken

**region**: the region for which the temperature anomaly was measured

**temp**: the temperature anomaly value for the given region and time period


### Widgets and Panels
The Shiny App consists of three panels:

**DataSet**: provides an overview of the dataset and displays a sample of five rows from the dataset.

**Plot**: allows you to visualize mean temperature anomalies over time for selected regions. You can choose the regions to display, and optionally hide/show the trend lines. The panel also shows the average temperature difference between two selected years.

**Table**: displays a table of temperature anomalies by region and month for a given range of years. You can select the columns to display, as well as the months and years to include.

To use the app, select the desired panel from the tabs at the top of the screen and use the provided widgets to adjust the data displayed.
