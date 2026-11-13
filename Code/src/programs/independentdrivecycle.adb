with Ada.Real_Time;
use Ada.Real_Time;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.MotorDriver;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;
with MicroBit.Radio; use MicroBit.Radio;
with HAL; use HAL;
with Protocol; use Protocol;

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
   TxData : RadioData;
   RxData : RadioData;
   Dir : MicroBit.MotorDriver.Car.Direction;
   Test_Val : UInt8 := 0;

begin
   TxData.Length := 4;
   TxData.Version := 12;
   TxData.Group := 37;
   TxData.Protocol := 14;

   Put_Line ("Heyyy from begin");

   Setup(RadioFrequency => 2416,
                Length   => TxData.Length,
                Version  => TxData.Version,
                Group    => TxData.Group,
                Protocol => TxData.Protocol);
   StartReceiving;

   Dir := Stopped;
   RxData.Length      := 4;
   RxData.Group       := 37;
   RxData.Payload (2) := 0;
   RxData.Payload (3) := 0;
   RxData.Payload (4) := 0;

   loop
      RxData.Payload (1) := Test_Val;
      Dir := Decode (RxData);
      Put_Line ("Test_Val=" & UInt8'Image (Test_Val) &
                " Dir=" & Direction'Image (Dir));

      Move (Dir, 2000);
      Put_Line ("Move returned");

      Test_Val := (Test_Val + 1) mod 7;
      delay until Clock + Milliseconds (1000);
      Move (Stopped, 0);
      delay until Clock + Milliseconds (500);
   end loop;
end Main;
