with Ada.Real_Time; use Ada.Real_Time;
with Car_Tasks;

procedure Main with Priority => 0 is
begin
   loop
      delay until Clock + Milliseconds (1000);
   end loop;
end Main;