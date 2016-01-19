#!/usr/bin/python

import smtplib

def blue_alert(msg):
    sender = 'fejlmails@gmail.com'
    receivers = ['thomas@tdavidsen.dk']

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.ehlo()
        server.starttls()
        server.ehlo()
        server.login("fejlmails@gmail.com","Sofie2015")
        server.sendmail(sender, receivers, msg)         
        print "Successfully sent email"
    except SMTPException:
        print "Error: unable to send email"
        
if __name__ == "__main__":
    mymsg = "From: Me <fejlmails@gmail.com>\nTo: You <thomas@tdavidsen.dk>\nSubject: Sensor Error \nThere is a problem with the temperture sensor."
    blue_alert(mymsg)
