import pymysql


def commitBDD(sql):
    connection = pymysql.connect(host='127.0.0.1',
                                 user='root',
                                 password='root',
                                 database='coco',
                                 port=8889)
    cursor = connection.cursor()
    cursor.execute(sql)
    connection.commit()
    cursor.close()
    connection.close()


def selectBDD(sql):
    connection = pymysql.connect(host='127.0.0.1',
                                 user='root',
                                 password='root',
                                 database='coco',
                                 port=8889)
    cursor = connection.cursor()
    cursor.execute(sql)
    rows = cursor.fetchall()
    cursor.close()
    connection.close()
    return rows
