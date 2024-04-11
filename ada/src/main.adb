with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   dim : constant Integer := 1000;
   thread_num : constant Integer := 5;
   arr : array(1..dim) of Integer;

   procedure Init_Arr is
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;
      arr(34) := -1000;
   end Init_Arr;

   function part_min (start_index, finish_index : in Integer) return Integer is
      index : Integer := start_index;
   begin
      for i in start_index..finish_index loop
         if arr(i) < arr(index) then
            index := Integer(i);
         end if;
      end loop;
      return index;
   end part_min;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min(index : in Integer);
      entry get_min(index : out Integer);
   private
      tasks_count : Integer := 0;
      index1 : Integer := 1;
   end part_manager;

   protected body part_manager is
      procedure set_part_min(index: in Integer) is
      begin
         if arr(index) < arr(index1) then
            index1 := index;
         end if;
         tasks_count := tasks_count + 1;
      end set_part_min;

      entry get_min(index : out Integer) when tasks_count = thread_num is
      begin
         index := index1;
      end get_min;
   end part_manager;

   task body starter_thread is
      index : Integer := 1;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      index := part_min(start_index => start_index,
                      finish_index => finish_index);
      part_manager.set_part_min(index);
   end starter_thread;

   function parallel_min return Integer is
      index : Integer := 0;
      thread : array(1..thread_num) of starter_thread;
      parts : Integer := dim / thread_num;
   begin
      for i in 1..thread_num loop
         thread(i).start(((i-1) * parts) + 1, parts * i);
      end loop;
      part_manager.get_min(index);
      return index;
      end parallel_min;
begin
   Init_Arr;
   Put_Line("Part_Min: " & Integer'Image(part_min(1, dim)) & " " & Integer'Image(arr(part_min(1, dim))));
   Put_Line("Parallel_Min: " & parallel_min'Img & " " & arr(parallel_min)'Img);
end Main;
