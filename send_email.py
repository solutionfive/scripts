from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.utils import parseaddr, formataddr
import smtplib

def _format_add(s):
    name, addr = parseaddr(s)
    return formataddr((Header(name, 'utf-8').encode(), addr))

from_addr = input('From: ')
password = input('Email Password: ')
to_addr = input('To: ')
smtp_server = 'smtp.gmail.com'
smtp_port = 587

msg = MIMEMultipart('alternative')
msg['From'] = _format_add('Python new fish <%s>' % from_addr)
msg['To'] = _format_add('Admin <%s>' % to_addr)
msg['Subject'] = Header('Please mark this email', 'utf-8').encode()

server = smtplib.SMTP('smtp.gmail.com:587')
server.ehlo()
server.starttls()
server.set_debuglevel(1)
server.login(from_addr, password)
server.sendmail(from_addr, [to_addr], msg.as_string())
server.quit()