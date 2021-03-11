default_data = [[0, 2, 0, 0, 0, 1, 0, 0, 0],
                [5, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 3, 0, 0, 0, 0, 4],
                [0, 6, 0, 0, 0, 0, 5, 0, 0],
                [0, 0, 0, 0, 7, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 2, 0, 0],
                [7, 0, 9, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 2, 0, 0, 8, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0]]


def print_sudoku(data): #打印最终数独破解结果
    for i in range(9):
        for j in range(9):
            print('{:^3}'.format(data[i][j]),end='')
        print('')

def build_data_list(data): #初始化，未每个空位建立备选数字列表
    data_list = []
    for y in range(9):
        for x in range(9):
            if data[y][x] == 0:
                data_list.append([(x, y), [1, 2, 3, 4, 5, 6, 7, 8, 9]])
    return data_list

def judge(data, x, y, num): #关键函数一，判断数字是否重复，是否允许填入
    if data[y].count(num) > 0: #行判断
        #print('error1')
        return False

    for col in range(9): #列判断
        if data[col][x] == num:
            #print('error2')
            return False

    for a in range(3): #九宫格判断
        for b in range(3):
            if data[a+3*(y//3)][b+3*(x//3)] == num:
                #print('error3')
                return False
    return True

def judge_num(data , x, y, num):
    for i in range(9):
        if i != x:
            if data[i][y] == num:
                # print (i,y)
                return False

    for j in range(9):
         if j != y:
             if data[x][j] == num:
                 # print(x,j)
                 return False

    for i in range(3):
        for j in range(3):
            if i != x%3 or j != y%3:
                if data[i+3*(x//3)][j+3*(y//3)] == num:
                    # print(i+3*(x//3),j+3*(y//3))
                    return False
    return True

def judge_sudoku(data):
    for a in range(9):
        for b in range(9):
            if data[a][b] > 0:
                res=judge_num(data,a,b,data[a][b])
                if res==False:
                    # print (a,b)
                    return False
    return True

def data_list_filter(data, data_list, start):
    for blank_index in range(start, len(data_list)):
        data_list[blank_index][1] = []
        for num in range(1,10):
            if judge(data, data_list[blank_index][0][0], data_list[blank_index][0][1], num):
                data_list[blank_index][1].append(num)
    return data_list

def fill_num(data, data_list, start):  #关键函数二，对有多个备选数字的位置循环猜数字。类似深度优先遍历算法，一旦某位置的数字judge为True，则允许开始下一位置的猜测；若某位置为False，则忽略。
    if start < len(data_list):
        one = data_list[start]
        for num in one[1]:
            if judge(data, one[0][0], one[0][1], num):
                data[one[0][1]][one[0][0]] = num
                tem_data = fill_num(data, data_list, start+1)
                if tem_data != None:
                    return tem_data
        data[one[0][1]][one[0][0]] = 0  #有可能再往后猜了好几步后才发现前面错误，此时需要将过程中的所有赋值操作清零。
    else:
        return data

def solve(data):
    jud=judge_sudoku(data)
    if jud==False:
        print('No solution')
        return data
    try:
        data_list = data_list_filter(data, build_data_list(data), 0)
        newdata = fill_num(data, data_list, 0)
        print_sudoku(newdata)
        return newdata
    except:
        print('No solution')
        return data

# print_sudoku(default_data)
# print('\n')
# solve(default_data)