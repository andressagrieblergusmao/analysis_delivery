This script performs a statistical analysis of delivery drivers’ waiting times as a function of the distance between restaurants and delivery locations. It uses data from a CSV file, where information from multiple restaurants is processed.

The main functionalities include data preprocessing, which involves converting and cleaning the distance column into numeric values, handling missing data, and converting data types. The script filters data by specific restaurants from a given list, groups the information, and calculates the average waiting time by distance.

It then fits several regression models — including linear, polynomial (degrees 2 and 3), robust (Huber), and logarithmic — to explore different relationships between distance and waiting time. The performance of each model is evaluated using the coefficient of determination (R²), which measures the quality of the fit.

Finally, it generates visualizations through scatter plots and regression curves to allow visual analysis of the data trends. The script uses pandas for data manipulation and cleaning, matplotlib for graphical visualization, and sklearn for regression modeling and performance metrics.
