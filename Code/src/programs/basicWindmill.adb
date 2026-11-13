with MicroBit.Console; use MicroBit.Console;
with MicroBit.DisplayRT; use MicroBit.DisplayRT;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.DisplayRT; use MicroBit.DisplayRT;
with MicroBit.DisplayRT.Symbols;
use MicroBit;

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
   Next : Time := Clock;
   dTime : constant Time_Span := Milliseconds(50);
begin
   Put_Line ("S <-- The zero means: Let's get started...");
   loop
      Clear;
      Set(4,4);
      Set(3,3);
      Set(2,2);
      Set(1,1);
      Set(0,0);

      Next := Next + dTime;
      delay until Next;

      Clear(4,4);
      Clear(0,0);

      Set(3,4);
      Set(1,0);

      Next := Next + dTime;
      delay until Next;

      Clear;
      Set(2,2);
      Set(2,1);
      Set(2,0);
      Set(2,4);
      Set(2,3);

      Next := Next + dTime;
      delay until Next;

      Clear;
      Set(2,2);
      Set(1,4);
      Set(1,3);
      Set(3,0);
      Set(3,1);

      Next := Next + dTime;
      delay until Next;

      Clear(3,0);
      Clear(1,4);
      Set(0,4);
      Set(4,0);

      Next := Next + dTime;
      delay until Next;

      Clear(0,4);
      Clear(4,0);
      Set(0,3);
      Set(4,1);

      Next := Next + dTime;
      delay until Next;

      Clear;
      Set(0,2);
      Set(1,2);
      Set(2,2);
      Set(3,2);
      Set(4,2);

      Next := Next + dTime;
      delay until Next;

      Clear;
      Set(2,2);
      Set(1,1);
      Set(3,3);
      Set(0,1);
      Set(4,3);

      Next := Next + dTime;
      delay until Next;

   end loop;
   loop
      null;
   end loop;
end Main;
