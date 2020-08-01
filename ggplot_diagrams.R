library(ggplot2)

#theme sets:
theme_set(theme_classic())
theme_set(theme_bw())

#load all csv files generated from the SQL queries:
data_one = read.csv("sheet_one.csv")
data_two = read.csv("sheet_two.csv")
data_three = read.csv("sheet_three.csv")
data_four = read.csv("sheet_four.csv")
data_five = read.csv("sheet_five.csv")
options(warn=-1)

# total number of rentals grouped by year/month and colored by store id
ggplot(data_one, aes(fill=as.factor(Store.ID), y=Rental, x=Year)) + 
  geom_bar(position="dodge", stat="identity") +
  labs(title = "Total Rental Orders By Shop") +
  ylab("Total Number Of Rentals") +
  xlab("Year And Month") +
  labs(fill ="Store ID")

# count quartiles of rental duration by category colored by quartiles
ggplot(data_two, aes(fill=as.factor(standard_quartile), y=rental_duration, x=category)) + 
  geom_bar(position="dodge", stat="identity") +
  labs(title = "Quartiles Of Rental Duration By Category") +
  ylab("Count") +
  xlab("Category") +
  labs(fill ="Quartile of Rental Duration")

# total rentals by category
ggplot(data_four, aes(x=category, y=nr_times_rented))+
  geom_bar(stat="identity", width = 0.5, fill="tomato2") + 
  labs(title="Total Rentals By Category") +
  theme(axis.text.x = element_text(angle=65, vjust=0.6))

# Total spend by month and top 10 customer
ggplot(data_three, aes(x=name, y=date, label=dollar_spent)) + 
  geom_point(stat='identity', fill="tomato2", size=11)  +
  geom_segment(aes(y = 0, 
                   x = name, 
                   yend = date, 
                   xend = name), 
               color = "black") +
  geom_text(color="white", size=2.5) +
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) +
  ylab("Year / Month") +
  xlab("Top 10 Customers") 
  labs(title="Top 10 Customers Lollipop", 
       subtitle="Total Spend By Month And Top 10 Customers") 

# Top 10 movies by total renvenue and total rents
ggplot(data_five, aes(x=file_title, y=total, label=nr_time_rented)) + 
  geom_point(stat='identity', fill="tomato2", size=11)  +
  geom_segment(aes(y = 0, 
                   x = file_title, 
                   yend = total, 
                   xend = file_title), 
               color = "black") +
  geom_text(color="white", size=2.5) +
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) +
  ylab("Total Amount In $") +
  xlab("Top 10 Movies By Revenue") +
  labs(title="Top 10 Movies Lollipop", 
     subtitle="Top 10 Movies By Total Renvenue And Rents") 
