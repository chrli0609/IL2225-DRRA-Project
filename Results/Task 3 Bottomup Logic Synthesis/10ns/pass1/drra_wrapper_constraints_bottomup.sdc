Information: Updating design information... (UID-85)
Warning: Design 'drra_wrapper' contains 6 high-fanout nets. A fanout number of 1000 will be used for delay calculations involving these nets. (TIM-134)
 
****************************************
Report : constraint
Design : drra_wrapper
Version: R-2020.09-SP5-3
Date   : Sat Jan  6 11:19:29 2024
****************************************


                                                   Weighted
    Group (max_delay/setup)      Cost     Weight     Cost
    -----------------------------------------------------
    clk                          7.61      1.00      7.61
    default                      0.00      1.00      0.00
    -----------------------------------------------------
    max_delay/setup                                  7.61

                              Total Neg  Critical
    Group (critical_range)      Slack    Endpoints   Cost
    -----------------------------------------------------
    clk                       2465.25        78    593.91
    default                      0.00         0      0.00
    -----------------------------------------------------
    critical_range                                 593.91

                                                   Weighted
    Group (min_delay/hold)       Cost     Weight     Cost
    -----------------------------------------------------
    clk (no fix_hold)            0.00      1.00      0.00
    default                      0.00      1.00      0.00
    -----------------------------------------------------
    min_delay/hold                                   0.00


    Constraint                                       Cost
    -----------------------------------------------------
    max_transition                                   7.49 (VIOLATED)
    max_capacitance                                  0.40 (VIOLATED)
    max_delay/setup                                  7.61 (VIOLATED)
    sequential_clock_pulse_width                     0.00 (MET)
    critical_range                                 593.91 (VIOLATED)


1
