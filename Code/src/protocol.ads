with MicroBit.Radio; use MicroBit.Radio;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;

package Protocol is
   Frequency : constant := 2416;
   Group     : constant := 1;

   function Decode (D : RadioData) return Direction;

   function Encode (Dir : Direction; Speed : Speed_Value) return RadioData;

   procedure Send (Dir : Direction; Speed : Speed_Value);

end Protocol;

