with Ada.Real_Time;
use Ada.Real_Time;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;
with MicroBit.Radio; use MicroBit.Radio;
-- USN PROJECT TEMPLATE INTELLIGENT REAL-TIME SYSTEMS
-- Project name: [project name]
-- Project members: [name, name, .. ]


--This is a project template for the MicroBit v2, built against the embedded-nrf52833
--runtime (a Ravenscar/Jorvik-style profile) so we have a language-supported real-time
--OS for embedded targets. The runtime ships with the gnat_arm_elf toolchain that Alire
--installs, so there is nothing to copy by hand.

--Check out the many examples in the ADL for the MicroBit v2 to see:
--  1) How the various drivers can be used like the accelerometer,speaker  or wireless communication via radio
--  2) How ADA features like the Math library and Bounded_Vectors (Containers) can be used
--  3) How to structure your Ada tasks with a protected object to synchronize data or with entries to synchronize flow
--  4) How to perform a execution time analysis
--  5) How to integrate your Ada project with a Unity project over USB

-- Open a View > Cross Platforms > Serial Ports to see Put_Line output. Set the baud rate to 115.200
procedure Main with Priority => 0 is
   Test_Speed : constant Speed_Value := 2000;
   Run_Time   : constant Time_Span   := Milliseconds (1500);
   Pause      : constant Time_Span   := Milliseconds (500);

   procedure Wait (T : Time_Span) is
   begin
      delay until Clock + T;
   end Wait;

   procedure Step (Dir : Direction) is
   begin
      Move(Dir, Test_Speed);
      Wait(Run_Time);
      Stop;
      Wait(Pause);
   end Step;

begin
   Wait(Milliseconds (2000)); -- time to put the car down

   Step(Forward);
   Step(Backward);
   Step(Left);
   Step(Right);

   Rotate(Clockwise, Test_Speed);
   Wait(Run_Time);
   Stop;
   Wait(Pause);

   Rotate(Counter_Clockwise, Test_Speed);
   Wait(Run_Time);
   Stop;

   

   loop
      Wait(Milliseconds(1000));
   end loop;
end Main;
