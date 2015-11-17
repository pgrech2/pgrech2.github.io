__author__ = 'Paul'

import pandas as pd
import re

# Input for file to be cleaned...
f = raw_input('File Number for cleaning: ')
csv = pd.read_csv('data/'+f+'_couples_prenltk.csv')


# Retaining columns of data frame needed for analysis
csv = csv[['Id', 'EventDate', 'City', 'Location',
             'MatchedFirstName', 'MatchedLastName',
             'Registrant2FirstName', 'Registrant2LastName',
             'RegistriesSummary', 'Websites']]

# Remove all observations that do not have a website
csv.dropna(subset = ['Websites'], inplace = True)

# Remove extra characters from API output wrapped around website address
csv['Websites'] = csv['Websites'].apply(lambda x:''.join(re.findall("(h.*)'", str(x.split(',')[0]))))

# Ensure website formatting is correct - testing
#print csv.Websites.head(10)

# Extract file number and save to new csv file
f = f[0]
csv.to_csv(f+'_filtered.csv')