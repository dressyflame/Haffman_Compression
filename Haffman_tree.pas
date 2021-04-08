type uk = ^elem;  //очередь для подсчета частоты вхождения символов в файл
  elem = record
    ch:char;
    sum:real;
    next:^elem
  end;
  
  leaf = ^node;       //листья дерева Хаффмана
  node = record
    l:^node;
    r:^node;
    p:real;
    ch:uk
  end;
  
  pq = ^que;    //очередь с приоритетом со ссылками на вершины
  que = record
    n:^node;
    next:^que
  end;
  
  

  
//добавление в очередь подсчета частоты вхождений
procedure add(l:^uk; c:char);
  var temp1,temp2:uk;
  begin
    temp1:= l^; temp2:= l^;
    while (temp1 <> nil) and (temp1^.ch <> c) do begin
      temp2:= temp1; temp1:= temp1^.next
    end;
    if (temp2 <> nil) then begin
      if (temp1 <> nil) then temp1^.sum := temp1^.sum + 1
      else begin
        new(temp2^.next);
        temp1:= temp2^.next;
        temp1^.ch := c;
        temp1^.sum := 1;
        temp1^.next := nil
      end
    end else begin
      new(l^);
      l^^.ch := c;
      l^^.next := nil;
    end
  end;

//подсчет частоты символов в тексте
procedure count_probability(l:^uk; f:file of char);

  var c:char; sum:real; t:uk;
  begin
    sum:=0;
    while not eof(f) do begin
      read(f,c); sum:= sum + 1;
      add(l, c)  
    end;
    t:= l^;
    while t <> nil do begin
      t^.sum := t^.sum / sum;
      t:= t^.next
    end;
  end;

//добавление элемента в очередь с приоритетом
procedure add_pq(l:^pq; n:leaf);
  var temp1, temp2:pq;
  
  begin
    temp1:= l^; temp2:= l^;
    while (temp1 <> nil) and (temp1^.n^.p < n^.p) do begin
      temp2:= temp1; temp1:= temp2^.next; 
    end;
    if (temp2 <> nil) then 
      if (temp1 = l^) then begin
        temp2 := nil;
        new(temp2);
        temp2^.next := l^;
        temp2^.n := n;
        l^:= temp2
      end else begin
        temp1 := temp2^.next;
        temp2^.next := nil;
        new(temp2^.next);
        temp2^.next^.n := n;
        temp2^.next^.next := temp1
    end else begin
      new(l^);
      l^^.n := n;
      l^^.next := nil;
    end
  end;

//построение приоритетной очереди из списка Uk  
procedure make_pq(q:^pq; l:uk);
  var temp:leaf;
  begin
    while (l <> nil) do begin
      new(temp);
      temp^.l := nil;
      temp^.r := nil;
      temp^.p := l^.sum;
      temp^.ch := l;
      l:= l^.next;
      temp^.ch^.next := nil;
      add_pq(q, temp); 
    end;
  end;

//взятие из приоритетной очереди наименее приоритетного элемента  
function pop(q:^pq):leaf;
  var temp:pq;
  begin
    pop:= q^^.n;
    temp:= q^;
    q^:= q^^.next;
    dispose(temp)
  end;

//построение дерева хаффмана
function make_tree(l:^pq):leaf;
  var temp:leaf;
  begin
    while (l^^.next <> nil) do begin
      new(temp);
      temp^.l := pop(l); temp^.r := pop(l);
      temp^.ch := nil;
      temp^.p := temp^.l^.p + temp^.r^.p;    
      add_pq(l, temp)
    end;
    make_tree:= pop(l);
  end;

//обход дерева хаффмана с выводом кодов
procedure inorder_tree(tree:leaf; code:string);
  begin
    if (tree^.l = nil) then begin 
      writeln('Symbol: ', tree^.ch^.ch, ' Probability = ',tree^.ch^.sum:0:5,' Ord = ',ord(tree^.ch^.ch), ' Code: ', code) ;
      dispose(tree)
    end else begin
      inorder_tree(tree^.l, code + '0');
      inorder_tree(tree^.r, code + '1')
    end;
  end;


var f : file of char; c : char; list, t: uk; queue:pq; tree:leaf;

begin
  assign (f, 'file.txt');
  reset (f);
  
  list:= nil;
  count_probability(@list, f);
  make_pq(@queue, list);
  tree:= make_tree(@queue);
  inorder_tree(tree, '');
  
  close(f)
end.
      
