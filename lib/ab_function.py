# all the functions defined

import pandas as pd

def step_hierarchy(df,column):
    # Define the hierarchy of process steps
    step_hierarchy = {
        'start': 1,
        'step_1': 2,
        'step_2': 3,
        'step_3': 4,
        'confirm': 5
    }
    # Map the step hierarchy to the 'process_step' column
    df.loc[:, 'step_hierarchy'] = df[column].map(step_hierarchy)
    return df

def highest_step_reached(df):
    step_hierarchy = {
        'start': 1,
        'step_1': 2,
        'step_2': 3,
        'step_3': 4,
        'confirm': 5
    }
    df2 = df.groupby('client_id')['step_hierarchy'].max()

    # Map the hierarchy back to step names
    df3 = df2.map({v: k for k, v in step_hierarchy.items()})
    return df2,df3

#Age group
#Young Adults: 0-30 years
#Middle-Aged Adults: 31-59 years
#Senior Adults: 60+ years

# Define a function to categorize age groups
def categorize_age(age):
    if age >= 0 and age <= 30:
        return 'Young Adults'
    elif age >= 31 and age <= 59:
        return 'Middle-Aged Adults'
    else:
        return 'Senior Adults'


# 0-10 Average Longevity Group
# 11-20 Above-Average Longevity Group
# 21+ Exceptional Longevity Group

def categorize_longevity(tenure_yr):

    if tenure_yr >= 0 and tenure_yr <= 10:
        return 'Average Longevity Clients'
    elif tenure_yr >= 11 and tenure_yr <= 20:
        return 'Above-Average Longevity Clients'
    else:
        return 'Exceptional Longevity Clients'
        
###NOT SURE WHAT THIS IS


#Low Balance:0 - 50,000
#Moderate Balance: 50,001- 500,000
#High Balance: 500,001- 1,000,000
#Very High Balance: 1,000,001+

def categorize_bal(bal):
    if bal >= 0 and bal <= 50000:
        return 'Low Balance'
    elif bal >= 50001 and bal <=  500000:
        return 'Moderate Balance'
    elif bal >=  500001 and bal <= 1000000:
        return 'High Balance'
    else:
        return 'Very High Balance'
    
###NOT SURE WHAT THIS IS
    

# Function to count backward movements
def count_backward_movements(group):
    error_count = 0
    previous_step = None
    
    for index, row in group.iterrows():
        current_step_hierarchy = row['step_hierarchy']
        
        if previous_step is not None and current_step_hierarchy < previous_step:
            error_count += 1
        
        elif previous_step is not None and current_step_hierarchy > previous_step + 1:
            error_count += 1
        
        previous_step = current_step_hierarchy
    
    return error_count

# Function to merge the table
def merge_multiple_col(df1,df2,columns):
    for column in columns:
        df1=df1.merge(df2[['client_id', column]], on='client_id', how='left')
    return df1