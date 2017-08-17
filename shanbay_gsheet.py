#!/root/.pyenv/versions/env2.7.13/bin/python2.7
# -*- coding: utf-8 -*-

import shanbay, gspread
from datetime import datetime, timedelta
from oauth2client.service_account import ServiceAccountCredentials


def login_shanbay():
    s = shanbay.Shanbay('15910684354', '681076')
    s.login()
    t = shanbay.Team(s, 'https://www.shanbay.com/team/detail/27502/')
    data = t.members()
    print 'Shanbay data have been generated.'
    return data


def login_gsheet():
    scope = ['https://spreadsheets.google.com/feeds']
    credentials = ServiceAccountCredentials.from_json_keyfile_name('/root/shanbay/key.json', scope)
    gc = gspread.authorize(credentials)
    wks = gc.open("Shanbay_sheet")
    gsheet_title = get_date()
    single_page = wks.add_worksheet(title=gsheet_title, rows='300', cols='10')
    single_page = wks.worksheet(gsheet_title)
    return single_page


def get_date():
    now = datetime.now()
    new_now = now + timedelta(hours=8)
    date_info = new_now.strftime('%Y-%m-%d-%H-%M')
    return date_info


def Write2sheet1(sheet, data):
    single_page = sheet
    single_page.update_acell('A1', 'Nickname')
    single_page.update_acell('B1', 'Days')
    single_page.update_acell('C1', 'Points')
    single_page.update_acell('D1', 'Rate')
    single_page.update_acell('E1', 'Checked_today')
    single_page.update_acell('F1', 'Checked_yesterday')
    single_page.update_acell('G1', 'Username')
    single_page.update_acell('H1', 'ID')
    single_page.update_acell('I1', 'Role')
    for i in range(len(data)):
        single_page.update_acell(str('A')+str(i+2), data[i]['nickname'])
        single_page.update_acell(str('B')+str(i+2), data[i]['days'])
        single_page.update_acell(str('C')+str(i+2), data[i]['points'])
        single_page.update_acell(str('D')+str(i+2), data[i]['rate'])
        single_page.update_acell(str('E')+str(i+2), data[i]['checked'])
        single_page.update_acell(str('F')+str(i+2), data[i]['checked_yesterday'])
        single_page.update_acell(str('G')+str(i+2), data[i]['username'])
        single_page.update_acell(str('H')+str(i+2), data[i]['id'])
        single_page.update_acell(str('I')+str(i+2), data[i]['role'])

    print 'Completed the page updates.'


def Write2sheet(sheet, data):
    single_page = sheet
    nickname_list = []
    days_list = []
    points_list = []
    rate_list = []
    checked_list = []
    checked_yesterday_list = []
    username_list = []
    id_list = []
    single_page.update_acell('A1', 'Nickname')
    single_page.update_acell('B1', 'Days')
    single_page.update_acell('C1', 'Points')
    single_page.update_acell('D1', 'Rate')
    single_page.update_acell('E1', 'Checked_today')
    single_page.update_acell('F1', 'Checked_yesterday')
    single_page.update_acell('G1', 'Username')
    single_page.update_acell('H1', 'ID')
    for i in range(len(data)):
        nickname_list.append(data[i]['nickname'])
        days_list.append(data[i]['days'])
        points_list.append(data[i]['points'])
        rate_list.append(data[i]['rate'])
        checked_list.append(data[i]['checked'])
        checked_yesterday_list.append(data[i]['checked_yesterday'])
        username_list.append(data[i]['username'])
        id_list.append(data[i]['id'])
    cell_listA = single_page.range('A2:A'+str(len(data)+1))
    cell_listB = single_page.range('B2:B'+str(len(data)+1))
    cell_listC = single_page.range('C2:C'+str(len(data)+1))
    cell_listD = single_page.range('D2:D'+str(len(data)+1))
    cell_listE = single_page.range('E2:E'+str(len(data)+1))
    cell_listF = single_page.range('F2:F'+str(len(data)+1))
    cell_listG = single_page.range('G2:G'+str(len(data)+1))
    cell_listH = single_page.range('H2:H'+str(len(data)+1))
    print 'Writing cell data.'
    Write_cell_list(single_page, cell_listA, nickname_list)
    Write_cell_list(single_page, cell_listB, days_list)
    Write_cell_list(single_page, cell_listC, points_list)
    Write_cell_list(single_page, cell_listD, rate_list)
    Write_cell_list(single_page, cell_listE, checked_list)
    Write_cell_list(single_page, cell_listF, checked_yesterday_list)
    Write_cell_list(single_page, cell_listG, username_list)
    Write_cell_list(single_page, cell_listH, id_list)

def Write_cell_list(sheet, cell_list, data_list):
    single_page = sheet
    count = 0
    for cell in cell_list:
        cell.value = data_list[count]
        count += 1
    single_page.update_cells(cell_list)

def main():
    user_data = login_shanbay()
    page_info = login_gsheet()
    Write2sheet(page_info, user_data)


if __name__ == '__main__':
    main()