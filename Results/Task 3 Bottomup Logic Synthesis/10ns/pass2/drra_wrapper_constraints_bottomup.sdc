Warning: There are infeasible paths detected in your design that were ignored during optimization. Please run 'report_timing -attributes' and/or 'create_qor_snapshot/query_qor_snapshot -infeasible_paths' to identify these paths.  (OPT-1721)
Information: Updating design information... (UID-85)
Warning: Design 'drra_wrapper' contains 4 high-fanout nets. A fanout number of 1000 will be used for delay calculations involving these nets. (TIM-134)
 
****************************************
Report : constraint
Design : drra_wrapper
Version: R-2020.09-SP5-3
Date   : Sat Jan  6 12:37:43 2024
****************************************


                                                   Weighted
    Group (max_delay/setup)      Cost     Weight     Cost
    -----------------------------------------------------
    clk                          2.95      1.00      2.95
    default                      0.00      1.00      0.00
    -----------------------------------------------------
    max_delay/setup                                  2.95

                              Total Neg  Critical
    Group (critical_range)      Slack    Endpoints   Cost
    -----------------------------------------------------
    clk                        848.92        30     88.41
    default                      0.00         0      0.00
    -----------------------------------------------------
    critical_range                                  88.41

                                                   Weighted
    Group (min_delay/hold)       Cost     Weight     Cost
    -----------------------------------------------------
    clk (no fix_hold)            0.00      1.00      0.00
    default                      0.00      1.00      0.00
    -----------------------------------------------------
    min_delay/hold                                   0.00


    Constraint                                       Cost
    -----------------------------------------------------
    max_transition                                   0.00 (MET)
    max_capacitance                                  0.00 (MET)
    max_delay/setup                                  2.95 (VIOLATED)
    sequential_clock_pulse_width                     0.00 (MET)
    critical_range                                  88.41 (VIOLATED)


1
