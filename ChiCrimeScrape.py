# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 15:42:31 2019

@author: Donald Ulfig
"""

import csv

writer=csv.writer(open('crimes.csv','w', newline=''))
with open('crimes.csv','w', newline='') as outfile:
    writer=csv.writer(outfile)
    with open('Crimes_-_2001_to_present.csv')as f:
        csv_reader=csv.reader(f,delimiter=',')
        count=0
        max_col=21
        x=''
        y=''
        p=''
        for row in csv_reader:
            if count==0:
                print(row[2]+row[5]+row[6]+row[7]+row[8]+row[9]+row[11]+row[17])
                count+=1
                writer.writerow([row[2],row[5],row[6],row[7],row[8],row[9],row[11],row[17]])
            else:
                if '2001' in row[2]:
                    x=row[2]
                    y=x[0:2]
                    p=x[6:10]
                    writer.writerow([y,row[5].translate({ord(','): None}),row[6].translate({ord(','): None}),row[7].translate({ord(','): None}),row[8].translate({ord(','): None}),row[9].translate({ord(','): None}),row[11].translate({ord(','): None}),p])
                    count+=1
                elif '2009' in row[2]:
                    x=row[2]
                    y=x[0:2]
                    p=x[6:10]
                    writer.writerow([y,row[5].translate({ord(','): None}),row[6].translate({ord(','): None}),row[7].translate({ord(','): None}),row[8].translate({ord(','): None}),row[9].translate({ord(','): None}),row[11].translate({ord(','): None}),p])
                    count+=1
                elif '2018' in row[2]:
                    x=row[2]
                    y=x[0:2]
                    p=x[6:10]
                    writer.writerow([y,row[5].translate({ord(','): None}),row[6].translate({ord(','): None}),row[7].translate({ord(','): None}),row[8].translate({ord(','): None}),row[9].translate({ord(','): None}),row[11].translate({ord(','): None}),p])
                    count+=1

    print(count,' completed')
        