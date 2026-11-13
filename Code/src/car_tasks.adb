with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO;
with MicroBit.MotorDriver;
with MicroBit.Ultrasonic;
with MicroBit.Types;           use MicroBit.Types;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;
with MicroBit.Radio;           use MicroBit.Radio;
with Protocol;                 use Protocol;
with MicroBit.Console;         use MicroBit.Console;
with MicroBit.Buttons;         use MicroBit.Buttons;
use MicroBit;
with System.Atomic_Primitives;
with Ada.Exceptions;

package body Car_Tasks is
   
   package SensorFront is new Ultrasonic (MB_P16, MB_P0);
   package SensorLeft  is new Ultrasonic (MB_P14, MB_P2);
   package SensorRight is new Ultrasonic (MB_P15, MB_P1);

   -- adjust only for testing individual task computation time
   --Run_Sense   : constant Boolean := True;
   --Run_Think   : constant Boolean := True;
   --Run_Execute : constant Boolean := True;

   type Readings is record
      Front  : Distance_cm := 100;
      Left   : Distance_cm := 100;
      Right  : Distance_cm := 100;
      Remote : Direction   := Stopped;
   end record;

   protected SensorReadings is
      procedure Put (R : Readings);
      function  Get return Readings;
   private
      Data : Readings;
   end SensorReadings;

   protected body SensorReadings is
      procedure Put (R : Readings) is
      begin
         Data := R;
      end Put;

      function Get return Readings is
      begin
         return Data;
      end Get;
   end SensorReadings;

   protected actionToPreform is
      procedure PutDir (Dir : Direction);
      procedure PutSpeed (Speed : Speed_Value);
      function GetDir return Direction;
      function GetSpeed return Speed_Value;
   private
      DataD  : Direction   := Stopped;
      DataS : Speed_Value := 3000;
   end actionToPreform;

   protected body actionToPreform is
      procedure PutDir (Dir : Direction) is
      begin
         DataD := Dir;
      end PutDir;

      procedure PutSpeed (Speed : Speed_Value) is
      begin
         DataS := Speed;
      end PutSpeed;

      function GetDir return Direction is
      begin
         return DataD;
      end GetDir;

      function GetSpeed return Speed_Value is
      begin
         return DataS;
      end GetSpeed;
   end actionToPreform;

   protected worstCaseComputationTime is
      procedure senseNewWorstCase (newWorst : Time_Span);
      procedure thinkNewWorstCase (newWorst : Time_Span);
      procedure actNewWorstCase   (newWorst : Time_Span);
      
      function getSense return Time_Span;
      function getThink return Time_Span;
      function getAct  return Time_Span;
   private
      senseWcct : Time_Span := Time_Span_Zero;
      thinkWcct : Time_Span := Time_Span_Zero;
      actWcct   : Time_Span := Time_Span_Zero;
   end worstCaseComputationTime;

   protected body worstCaseComputationTime is
      procedure senseNewWorstCase (newWorst : Time_Span) is
      begin
         if newWorst > senseWcct then senseWcct := newWorst; end if;
      end senseNewWorstCase;

      procedure thinkNewWorstCase (newWorst : Time_Span) is
      begin
         if newWorst > thinkWcct then thinkWcct := newWorst; end if;
      end thinkNewWorstCase;

      procedure actNewWorstCase (newWorst : Time_Span) is
      begin
         if newWorst > actWcct then actWcct := newWorst; end if;
      end actNewWorstCase;

      function getSense return Time_Span is (senseWcct);
      function getThink return Time_Span is (thinkWcct);
      function getAct   return Time_Span is (actWcct);
   end worstCaseComputationTime;

--------------------------------------------------------
------------------   TASK-START   ----------------------
--------------------------------------------------------

   task body Sense is
      Next : Time := Clock;
      RxData : RadioData;
      R : Readings;
      Last_Packet : Time := Clock;

      LastFront : Distance_cm := 100;
      LastLeft  : Distance_cm := 100;
      LastRight : Distance_cm := 100;

      -- Last_A : Button_State := Released;

      Start    : Time;

      MAX_ZEROS : constant := 3;
      ZeroFront, ZeroLeft, ZeroRight  : Natural := 0;

      lastReadRight : Boolean := false;

      procedure FilterReading (Value : in out Distance_cm;
                               Last  : in out Distance_cm;
                               Zeros : in out Natural) is
      begin
         if Value = 0 then
            if Zeros <= MAX_ZEROS then -- keeps value before checking sensor MAX_ZEROS times
               Zeros := Zeros + 1;
            end if;

            if MAX_ZEROS < Zeros then
               if Last < 20 then
                  Value := Last;   -- was close before the zeros: too close for the sensor, keep it close
               else
                  Value := 100;    -- zeros for a while, assumes nothing in range
                  Last  := 100;
               end if;
            else
               Value := Last; -- just a few zeros, probably a glitch or faulty sensor value, use last value
            end if;
         else
            Zeros := 0;
            Last  := Value;
         end if;
      end FilterReading;
   begin
      --if not Run_Sense then delay until Time_Last; end if;
      Setup (RadioFrequency => 2416,
             Length         => 4,
             Version        => 12,
             Group          => 37,
             Protocol       => 14);
      StartReceiving;

      loop
         Start := Clock;
         while DataReady loop
            RxData      := Receive;
            R.Remote    := Decode (RxData);
            Last_Packet := Clock;
         end loop;

         if Clock - Last_Packet > Milliseconds (500) then
            R.Remote := Stopped;   -- no packets for 0.5 s: stop
         end if;                   -- ensures, no endless driving when without signal

         R.Front := SensorFront.Read;
         FilterReading (Value => R.Front, Last => LastFront, Zeros => ZeroFront);

         -- check which side its strafing towards, otherwise alternates sensors.
         -- this reduces computation time, thus allowing us to get away with a lower period rather than sensing all sensors every time.
         if R.Remote = Right then       -- strafing right: watch the right side every loop
            lastReadRight := False;
         elsif R.Remote = Left then     -- strafing left: watch the left side every loop
            lastReadRight := True;
         end if;

         if lastReadRight then
            R.Left  := SensorLeft.Read ;
            FilterReading (Value => R.Left,  Last => LastLeft,  Zeros => ZeroLeft );
         else
            R.Right := SensorRight.Read;
            FilterReading (Value => R.Right, Last => LastRight, Zeros => ZeroRight);
         end if;
         lastReadRight := not lastReadRight;

         SensorReadings.Put(R);
         worstCaseComputationTime.senseNewWorstCase(Clock - Start);

         --if State (Button_A) = Pressed and Last_A = Released then -- print once per press
          --  Put_Line ("Sense:" & Duration'Image (To_Duration (worstCaseComputationTime.getSense)));
          --  Put_Line ("Think:" & Duration'Image (To_Duration (worstCaseComputationTime.getThink)));
          --  Put_Line ("Act:  " & Duration'Image (To_Duration (worstCaseComputationTime.getAct)));
         --end if;
         --Last_A := State(Button_A);

         Next := Next + Milliseconds (60);
         
         delay until Next;
      end loop;
   end Sense;

   task body Think is
      Next         : Time        := Clock;
      R            : Readings;
      DirToDrive   : Direction   := Stopped;
      SpeedToDrive : Speed_Value := 3000;

      Start  : Time;
      Last_A : Button_State := Released;

      function Speed_For (D : Distance_cm) return Speed_Value is
         StopAt   : constant         := 10;
         FullAt   : constant         := 60;
         MinSpeed : constant         := 1500;
         MaxSpeed : constant integer := integer(Speed_Value'Last);
      begin
         if    D <= StopAt then return 0;
         elsif D >= FullAt then return Speed_Value'Last;
         else
            return Speed_Value(MinSpeed + (MaxSpeed - MinSpeed) *
                               (Integer(D) - StopAt) / (FullAt - StopAt));
         end if;
      end Speed_For;
   begin
      --if not Run_Think then delay until Time_Last; end if;
      loop
         Start := Clock;
         R := SensorReadings.Get;

         DirToDrive := R.Remote;

         case DirToDrive is
            when Forward                    => SpeedToDrive := Speed_For(R.Front);
            when Backward                   => SpeedToDrive := 1500; -- no sensors behind, drive slower
            when Left                       => SpeedToDrive := Speed_For(R.Left);
            when Right                      => SpeedToDrive := Speed_For(R.Right);
            when Rotating_CCW | Rotating_CW =>
               if R.Right > 8 and R.Left > 8 and R.Front > 5 then
                  SpeedToDrive := 2000;
               else
                  SpeedToDrive := 0;
               end if;
            when others                     => SpeedToDrive := 0;
         end case;

         actionToPreform.PutDir(DirToDrive);
         actionToPreform.PutSpeed(SpeedToDrive);
         worstCaseComputationTime.thinkNewWorstCase(Clock - Start);

         
         if State (Button_A) = Pressed and Last_A = Released then -- print once per press
            Put_Line ("Sense:" & Duration'Image (To_Duration (worstCaseComputationTime.getSense)));
            Put_Line ("Think:" & Duration'Image (To_Duration (worstCaseComputationTime.getThink)));
            Put_Line ("Act:  " & Duration'Image (To_Duration (worstCaseComputationTime.getAct)));
         end if;
         Last_A := State(Button_A);
         Next := Next + Milliseconds (20);
         delay until Next;
      end loop;
   exception
      when others =>
         Put_Line ("Think crashed");
         loop
            actionToPreform.PutDir(Stopped);
            delay until Clock + Milliseconds (1000);
         end loop;
   end Think;

   task body Execute is
      Next       : Time := Clock;
      Speed      : Speed_Value;
      Dir        : Direction;
      Last_Dir   : Direction := Stopped;
      Last_Speed : Speed_Value := 0;
      Target     : Speed_Value;
      Ramp_Step  : constant := 100;   -- max speed increase per 20 ms (0 to full in ~0.4 s)
      Start      : Time;
      Last_A     : Button_State := Released;

   begin
      --if not Run_Execute then delay until Time_Last; end if;
      loop
         Start  := Clock;
         Target := actionToPreform.GetSpeed;
         Dir    := actionToPreform.GetDir;
         
         if Dir /= Last_Dir then
            Speed := 1500;
         else
            Speed := Last_Speed;
         end if;

         if Target < Speed then
            Speed := Target; -- brake immediately, more crucial than acceleration
         else
            Speed := Speed_Value'Min (Target, Speed + Ramp_Step);  -- accelerate gradually
         end if;

         if Dir /= Last_Dir or Speed /= Last_Speed then
            Move (Dir, Speed);
            Last_Dir   := Dir;
            Last_Speed := Speed;
         end if;

         worstCaseComputationTime.actNewWorstCase(Clock - Start);

         --if State (Button_A) = Pressed and Last_A = Released then -- print once per press
            --Put_Line ("Sense:" & Duration'Image (To_Duration (worstCaseComputationTime.getSense)));
            --Put_Line ("Think:" & Duration'Image (To_Duration (worstCaseComputationTime.getThink)));
            --Put_Line ("Act:  " & Duration'Image (To_Duration (worstCaseComputationTime.getAct)));
         --end if;
         --Last_A := State(Button_A);

         Next := Next + Milliseconds (20);
         delay until Next;
      end loop;
   end Execute;

end Car_Tasks;