__author__ = 'Paul Grech'
# Date = October 31st 2015
# Project 3

import string
import json
import pandas as pd
from urllib2 import Request, urlopen
from pandas.io.json import json_normalize
from datetime import date
import time



# Create iterable list of first and last names (2 letters)
def iterate(let):
    first_names = []
    last_names = []
    for i in range(len(let)):
        for j in range(len(let)):
            for k in range(len(let)):
                for l in range(len(let)):
                    first = let[k] + let[l]
                    last = let[i] + let[j]
                    if first == 'aa' or first[0] != first[1]:
                        first_names.append(first)
                        last_names.append(last)

    return(first_names, last_names)

def isName(text):
    tokens = nltk.word_tokenize(text)
    pos = nltk.pos_tag(tokens)
    tag = pos[0]
    if re.search('N{2}.?', tag[1]) != None:
        return True
    else:
        return False

################################################################################################################

# Enable / Disable Test Mode
# Full script with file designator
# test = 'run'
# Full script from subset of letters
test = 'test'

# Select which server file this is: 0-9
# File correlates with which bin of letters will be scraped for
file = 0


if test == 'test':
    # Test Parameters
    letters = ['a', 'b']
    (fn, ln) = iterate(letters)
    month = '0'
    year = '2016'

    #Initialization print outs
    print "First Name: ", fn
    print "Last Name: ", ln
    print "Month: ", month
    print "Year: ", year

    # Save data once complete
    length = len(fn)
    bins = [length-1]
    cbin = 0

else:
    # API Time parameters:
    letters = list(string.ascii_lowercase)
    (fn, ln) = iterate(letters)
    month = '0'
    year = '0'

    # API first name / last name parameters:
    #   Create letter bin depending on file designator (0-9)
    letters_bin = len(fn) / 10
    start_letters = file * letters_bin
    if start_letters + letters_bin - 1 > len(fn):
        end_letters = len(fn)
    else:
        end_letters = start_letters + letters_bin - 1

    fn = fn[start_letters:end_letters]
    ln = ln[start_letters:end_letters]

    # Create bins for output
    length = len(fn)
    cbin = 0
    bin_size = len(fn) / 4 - 1
    bin1 = 0 + bin_size
    bin2 = bin1 +bin_size + 1
    bin3 = bin2 +bin_size + 1
    bin4 = length - 1
    bins = [bin1, bin2, bin3, bin4]


# Initializations
column_init = [u'CharityName', u'CharityUrl', u'City', u'Country', u'CreateDate', u'EventDate', \
              u'EventType', u'Id', u'Location', u'MatchedFirstName', u'MatchedLastName', \
               u'OurRegistryUrl', u'Registrant2FirstName', u'Registrant2LastName', u'RegistriesSummary', \
               u'SearchScore', u'State', u'UgvrShortUrl', u'UserId', u'VisableRegistryCount', u'Websites', u'Zip']

couples = pd.DataFrame(columns = column_init)           # Temp DF containing one pull request
couples_raw = pd.DataFrame(columns = column_init)       # Complete DF containing all data
couples_prenltk = pd.DataFrame(columns = column_init)   # Complete DF containing all FILTERED data

# REMOVED - NLTK data frames
#couples_filtered = pd.DataFrame(columns = column_init) # Filtered - contains REAL names
#couples_removed = pd.DataFrame(columns = column_init)  # Removed - contains FAKE names

# Todays date for filtering
today = date.today()


for iter in range(length):

    # Print current iteration in test mode
    if test == 'test':
        print "First Name: ", fn[iter]
        print "Last Name: ", ln[iter]
        print "Iteration: ", iter

    # Pull request delay
    time.sleep(1)
    path = ‘RemovedForPrivacy’+\
	   ‘?firstName='+fn[iter]+\
           '&lastName='+ln[iter]+\
           '&eventMonth='+month+\
           '&eventYear='+year+\
           ‘RemovedForPrivacy’
    request = Request(path)
    response = urlopen(request)
    data = response.read()
    data_json = json.loads(data)

    try:
        data_json['ResultCount'] > 0
    except:
        couples['MatchedFirstName'] = fn[iter]
        couples['MatchedLastName'] = ln[iter]
        couples['Id'] = 0
    else:
        if data_json['ResultCount'] > 0:

            # Json to DF
            couples = json_normalize(data_json['Couples'])

            # Add Current scrape of all raw values to previous scrapes
            couples_raw = pd.concat([couples_raw,couples])

            # State Filter
            couples = couples[(couples.State == 'NY') | (couples.State == 'NJ') | (couples.State == 'CT')]

            # Date Filter
            couples['EventDate'] = pd.to_datetime(couples.EventDate.str[0:10])
            couples = couples[couples.EventDate >= today]

            # Reindex Pandas dataframe for Name Filter iteration
            len = couples.shape[0]
            couples.index = range(len)

            # Save post filtered data containing all names
            couples_prenltk = pd.concat([couples_prenltk,couples])

            # Filter by 'real' and 'fake' names
            # Not implemented. Was not accurate for unique names
            # for couple in range(len):
            #     if isName(couples.MatchedFirstName[couple]) == True:
            #         couples_filtered = pd.concat([couples_filtered,couples.iloc[[couple]]])
            #     else:
            #         couples_removed = pd.concat([couples_removed,couples.iloc[[couple]]])


        # Save every time a bin is complete
        if iter in bins:
            cbin +=1
            couples_prenltk.to_csv(str(file)+'_'+str(cbin)+'_couples_prenltk.csv',encoding='utf-8')
            #couples_raw.to_csv(str(file)+'_'+str(cbin)+'_couples_raw.csv',encoding='utf-8')
            #couples_removed.to_csv(str(file)+'_'+str(cbin)+'_couples_removed.csv',encoding='utf-8')
            #couples_filtered.to_csv(str(file)+'_'+str(cbin)+'_couples_filtered.csv',encoding='utf-8')






