package Car_Tasks is
   task Sense   with Priority => 1; -- T = 60 ms
   task Think   with Priority => 3; -- T = 20 ms
   task Execute with Priority => 2; -- T = 20 ms
end Car_Tasks;