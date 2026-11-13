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

   loop
      while DataReady loop
         RxData := Receive;
         Put_Line ("Len=" & UInt8'Image (RxData.Length) &
          " Grp=" & UInt8'Image (RxData.Group) &
          " P1="  & UInt8'Image (RxData.Payload (1)) &
          " P2="  & UInt8'Image (RxData.Payload (2)) &
          " P3="  & UInt8'Image (RxData.Payload (3)) &
          " P4="  & UInt8'Image (RxData.Payload (4)));
         
         Dir := Decode(RxData);
      end loop;

      Put_Line (Uint8'Image (RxData.Payload(1)));
      
      if Dir /= Stopped then
         Move (Dir, 2000);
      else
         Move (Stopped, 2000);
      end if;

      

   end loop;
end Main;
