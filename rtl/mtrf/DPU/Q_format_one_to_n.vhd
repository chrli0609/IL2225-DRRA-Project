-------------------------------------------------------
--! @file Q_format_one_to_n.vhd
--! @brief Combinatorial Unit that changes Q format. Selectable format in output, fixed in input
--! @details 
--! @author Guido Baccelli
--! @version 1.0
--! @date 2021-02-16
--! @bug NONE
--! @todo NONE
--! @copyright  GNU Public License [GPL-3.0].
-------------------------------------------------------
---------------- Copyright (c) notice -----------------------------------------
--
-- The VHDL code, the logic and concepts described in this file constitute
-- the intellectual property of the authors listed below, who are affiliated
-- to KTH(Kungliga Tekniska Högskolan), School of EECS, Kista.
-- Any unauthorised use, copy or distribution is strictly prohibited.
-- Any authorised use, copy or distribution should carry this copyright notice
-- unaltered.
-------------------------------------------------------------------------------
-- Title      : Combinatorial Unit that changes Q format. Selectable format in output, fixed in input
-- Project    : SiLago
-------------------------------------------------------------------------------
-- File       : Q_format_one_to_n.vhd
-- Author     : Guido Baccelli
-- Company    : KTH
-- Created    : 06/02/2019
-- Last update: 2021-02-16
-- Platform   : SiLago
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Contact    : Dimitrios Stathis <stathis@kth.se>
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 06/02/2019  1.0      Guido Baccelli      Created
-------------------------------------------------------------------------------

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
--                                                                         #
--This file is part of SiLago.                                             #
--                                                                         #
--    SiLago platform source code is distributed freely: you can           #
--    redistribute it and/or modify it under the terms of the GNU          #
--    General Public License as published by the Free Software Foundation, #
--    either version 3 of the License, or (at your option) any             #
--    later version.                                                       #
--                                                                         #
--    SiLago is distributed in the hope that it will be useful,            #
--    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
--    GNU General Public License for more details.                         #
--                                                                         #
--    You should have received a copy of the GNU General Public License    #
--    along with SiLago.  If not, see <https://www.gnu.org/licenses/>.     #
--                                                                         #
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

--! Standard ieee library
LIBRARY ieee;
--! Standard logic package
USE ieee.std_logic_1164.ALL;
--! Standard numeric package for signed and unsigned
USE ieee.numeric_std.ALL;
--! Package for math with real numbers
USE IEEE.math_real.ALL;
--! Package for misc functions
USE work.util_package.ALL;

--! @brief This module converts input data from a Q format to another. Fixed format in input, selectable in output
--! @details In this current version, the num. of fractional bits 'frac_part' is just a generic, but the unit is already configured to
--! function if 'frac_part' is turned into a run-time dynamic input
ENTITY Q_format_one_to_n IS
  GENERIC (
    Nb        : INTEGER;
    frac_part : INTEGER;      --! Size of output fractional part
    in_fp     : INTEGER := 11 --! Size of input fractional part
  );
  PORT (
    d_in  : IN signed(Nb - 1 DOWNTO 0);
    d_out : OUT signed(Nb - 1 DOWNTO 0)
  );
END ENTITY;

--! @brief Structural definition of Q_format_n_to_one
--! This component takes an input with Q format that can be changed at compile-time, 
--! and converts it to an output with run-time selectable format. Input data is used to obtain the outputs bit strings for all possible Q formats. These
--! are then sent to a multiplexer, that selects the correct output basing on the Q format signal coming from input
--! NOTE: In this current version, the num. of fractional bits 'frac_part' is just a generic, but the unit is already configured to
--! function if 'frac_part' is turned into a run-time dynamic input
ARCHITECTURE structural OF Q_format_one_to_n IS

  CONSTANT in_ip : INTEGER := Nb - in_fp;

  SUBTYPE frac_part_range IS INTEGER RANGE 0 TO Nb - 1;
  SUBTYPE output_frac_gt_input_frac_range IS INTEGER RANGE in_fp + 1 TO Nb - 1;
  TYPE array_output IS ARRAY(frac_part_range) OF signed(Nb - 1 DOWNTO 0);

  SIGNAL output_cuts                    : array_output;
  SIGNAL max_outs_array, min_outs_array : array_output;
  SIGNAL final_max_out, final_min_out   : signed(Nb - 1 DOWNTO 0);
  SIGNAL input_sat                      : signed(Nb - 1 DOWNTO 0);
BEGIN

  maxmin_out_gen : FOR i IN frac_part_range GENERATE
    true_cond : IF i > in_fp GENERATE
      --! generates the maximum number for the output Q format, but represented on the input Q format
      max_outs_array(i) <= to_signed(2 ** (Nb - (i - in_fp) - 1) - 1, max_outs_array(i)'length);
      --! generates the minimum number for the output Q format, but represented on the input Q format
      min_outs_array(i) <= to_signed(-2 ** (Nb - (i - in_fp) - 1), min_outs_array(i)'length);
    END GENERATE;
    false_cond : IF i < in_fp + 1 GENERATE
      max_outs_array(i) <= (OTHERS => '0');
      min_outs_array(i) <= (OTHERS => '0');
    END GENERATE;
  END GENERATE;

  final_max_out <= max_outs_array(frac_part);
  final_min_out <= min_outs_array(frac_part);

  --! Saturation of input data on the Q format
  sat_int_proc : PROCESS (d_in, final_max_out, final_min_out)
  BEGIN
    IF d_in > final_max_out THEN
      input_sat <= final_max_out;
    ELSIF d_in < final_min_out THEN
      input_sat <= final_min_out;
    ELSE
      input_sat <= d_in;
    END IF;
  END PROCESS;
  -- Output generation
  output_gen : FOR i IN frac_part_range GENERATE
    --! If output fractional part is smaller than the input one, cut the input decimal bits
    out_frac_lt_in_frac : IF i < in_fp + 1 GENERATE
      output_cuts(i) <= resize(d_in(d_in'length - 1 DOWNTO in_fp - i), output_cuts(i)'length);
    END GENERATE;
    --! If output frac part is bigger than the input one, copy the saturated input data to the most significant bits and zero pad
    out_frac_gteq_in_frac : IF i > in_fp GENERATE
      output_cuts(i) <= shift_left(input_sat, i - in_fp);
    END GENERATE;
  END GENERATE;

  d_out <= output_cuts(frac_part);

END ARCHITECTURE;