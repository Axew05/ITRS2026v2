with MicroBit.Radio; use MicroBit.Radio;
with HAL; use HAL;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.Accelerometer;
with MicroBit.Buttons; use MicroBit.Buttons;
with LSM303AGR; use LSM303AGR;
with Ada.Real_Time; use Ada.Real_Time;
use MicroBit; 

procedure Main is
RxData : RadioData; 
TxData : RadioData;
dummy : Boolean := True;
Data : All_Axes_Data;
payload : UInt8;
thershold : constant := 150;

begin
TxData.Length := 4; 
TxData.Version := 12;
TxData.Protocol := 14;
TxData.Group := 37;

Setup (RadioFrequency => 2416, Length => TxData.Length, Version => TxData.Version, Group => TxData.Group, Protocol => TxData.Group);
Put_line(State);


loop
 payload := 0;
 Data := Accelerometer.AccelData;
 --Put_line("X:" & Data.X'Image);
 --Put_Line ("Button A: "& Buttons.State(Button_A)'Image & "   " &"Button B> " & Buttons.State(Button_B)'Image);
 
 if(Buttons.State(Button_A) = Pressed) then
 payload := 5;
 elsif(Buttons.State(Button_B) = Pressed) then
 payload := 6;
 elsif(Data.Y > thershold) then 
 Put_line("Forward"); 
 payload := 1;
 elsif(Data.Y < -thershold) then 
 Put_Line ("Backwards");
 payload := 2;
 elsif(Data.X < -thershold) then
 Put_Line ("CrW Right");
 payload := 3;
 elsif(Data.X > thershold) then
 Put_Line ("CrW Left");
 payload := 4;
 end if;

 if(payload <= 6) then
 TxData.Payload(1) := payload;
 end if;
 
 Put_line("Data sent: " & payload'Image);
 Transmit (TxData);
 delay 0.05;
end loop;
end Main;