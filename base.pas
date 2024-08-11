program roman;

const 
      FILE_NAME = 'base.bin';
      HEADER = '------------- Главное меню --------------';
      SEPARATOR = '-----------------------------------------';    

type
     ssn_string = string[11];
     data_rec = record
        id: string[5];
        names, position: string[10];
        ssn: ssn_string;
        rate: real;
     end;


     list_ptr = ^list_rec;
     list_rec = record 
        data_field: data_rec;
        next_field: list_ptr;
     end;
    
     worker_file = file of data_rec;

var 
    first_ptr: list_ptr;
    list_file: worker_file;

procedure search_list(first_ptr: list_ptr;
                      var second_ptr: list_ptr;
                      var next_ptr: list_ptr;
                      ssn_number: ssn_string;
                      var found: boolean);
begin
    next_ptr := nil;
    second_ptr := first_ptr;

    while (second_ptr <> nil) and (not found) do 
        if second_ptr^.data_field.ssn = ssn_number then 
            found := true
        else
        begin
            next_ptr := second_ptr;
            second_ptr := second_ptr^.next_field;
        end;       
end;

procedure build_list(var first_ptr: list_ptr;
                     data_item: data_rec);
var 
     next_ptr: list_ptr;
begin
    new(next_ptr);
    next_ptr^.data_field := data_item;
    next_ptr^.next_field := first_ptr;
    first_ptr := next_ptr;
end;

procedure read_list(first_ptr: list_ptr);
var second_ptr: list_ptr;
begin
    second_ptr := first_ptr;
    while second_ptr <> nil do 
    begin
        with second_ptr^.data_field do 
        begin
            write(id: 5);
            write(names: 10);
            write(position: 13);
            write(ssn: 11);
            writeln(rate:8:1, '$');
        end;
        second_ptr := second_ptr^.next_field;
    end;
    writeln;
end;

procedure del_rec(var first_ptr: list_ptr);
var 
    second_ptr, next_ptr: list_ptr;
    found: boolean;
    ssn_number: ssn_string;
begin
    found := false;
    writeln(separator);
    write('Введите номер SSN сотрудника: ');
    readln(ssn_number);
    search_list(first_ptr, second_ptr, next_ptr, ssn_number, found);

    if not found then 
        writeln('SSN ', ssn_number, ' не найден')
    else 
    begin
        if next_ptr = nil then 
            first_ptr := first_ptr^.next_field
        else 
            next_ptr^.next_field := second_ptr^.next_field;
        dispose(second_ptr);
        writeln('Запись удалена из списка');
        writeln;
    end;
end;

procedure get_data(var first_ptr: list_ptr);
var 
    second_ptr, dummy_ptr: list_ptr;
    item: data_rec;
    ssn_number: ssn_string;
    found: boolean;
begin
    found := false;
    write('Введите номер SSN сотрудника: ');
    readln(ssn_number);
    search_list(first_ptr, second_ptr, dummy_ptr, ssn_number, found);

    if not found then 
    begin
        writeln('Введите информацию о сотруднике: ');
        with item do 
        begin
            ssn := ssn_number;
            write('ID: '); readln(id);
            write('Имя: '); readln(names);
            write('Должность: '); readln(position);
            write('Тариф: '); readln(rate);
            writeln(separator);
        end;    
        build_list(first_ptr, item);
        writeln('Сотрудник добавлен в список');
        writeln;
    end
    else 
        writeln('SSN ', ssn_number, ' уже в списке');
end;

procedure distplay_it_all(first_ptr: list_ptr);
begin
    writeln(separator);
    writeln('Содержимое списка: ');
    writeln('ID':5, 'Имя':13, 'Position':13, 'SSN':11, 'Rate':9);
    writeln;
    read_list(first_ptr);

end;

procedure display_rec(first_ptr: list_ptr);
var 
    second_ptr, dummy_ptr: list_ptr;
    found: boolean;
    ssn_number: ssn_string;
begin
    found := false;
    writeln(separator);
    write('Введите номер SSN сотрудника: ');
    readln(ssn_number);
    search_list(first_ptr, second_ptr, dummy_ptr, ssn_number, found);
    if not found then  
        writeln('SSN ', ssn_number, ' не найден')
    else 
        with second_ptr^.data_field do 
        begin
            writeln('ID: ', id);
            writeln('Имя: ', names);
            writeln('Должность: ', position);
            writeln('Номер соц страха: ', ssn);
            writeln('Почасовой тариф: ', rate:2:2);
        end;
    writeln
end;

procedure update_rec(var first_ptr: list_ptr);
var 
    second_ptr, dummy_ptr: list_ptr;
    ssn_number: ssn_string;
    found: boolean;
begin
    found := false;
    writeln(separator);
    write('Введите номер SSN сотрудника: ');
    readln(ssn_number);
    search_list(first_ptr, second_ptr, dummy_ptr, ssn_number, found);
    
    if not found then 
        writeln('SSN ', ssn_number, ' не найден')
    else 
        with second_ptr^.data_field do 
        begin
            writeln('Введите новую информацию о сотруднике',
            '(SSN: ', ssn_number, '):');
            write('ID: '); readln(id);
            write('Имя: '); readln(names);
            write('Должность: '); readln(position);
            write('Почасовой тариф: '); readln(rate);
            writeln('Запись обновлена');
            writeln;
        end;
end;

procedure save_list(first_ptr: list_ptr; 
                    var list_file: worker_file);
var 
    second_ptr: list_ptr;
begin
    assign(list_file, file_name);
    rewrite(list_file);

    second_ptr := first_ptr;
    while second_ptr <> nil do 
    begin
        write(list_file, second_ptr^.data_field);
        second_ptr := second_ptr^.next_field;
    end;
    close(list_file);
    writeln('Список сохранен в файле');
    writeln;
end;

procedure read_file(var first_ptr: list_ptr; 
                    var list_file: worker_file);
var 
    item: data_rec;
begin
    assign(list_file, file_name);
    reset(list_file);
    while not eof(list_file) do 
    begin
        read(list_file, item);
        build_list(first_ptr, item);
    end;
    close(list_file);
    writeln('Список сотрудников уже в памяти');
end;


procedure menu;
var option: integer;
begin
   writeln(header);
   writeln('1. Добавить записи в список');
   writeln('2. Вывести на экран весь список');
   writeln('3. Вывести на экран запись о сотруднике');
   writeln('4. Добавить записи из файла');
   writeln('5. Сохранить список в файле');
   writeln('6. Удалить запись');
   writeln('7. Обновить запись');
   writeln('8. Выход');
   writeln(separator);
   write('Сделайте выбор и нажмите цифру: ');
   readln(option);

   case option of
        1: get_data(first_ptr);
        2: distplay_it_all(first_ptr);
        3: display_rec(first_ptr);
        4: read_file(first_ptr, list_file);
        5: save_list(first_ptr, list_file);
        6: del_rec(first_ptr);
        7: update_rec(first_ptr);
        8: Exit;
   end;
   menu;
end;

begin
    first_ptr := nil;
    menu;
end.