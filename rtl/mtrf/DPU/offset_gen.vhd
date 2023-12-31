-------------------------------------------------------
--! @file offset_gen.vhd
--! @brief Offset generator for Squash unit
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
-- Title      : Offset generator for Squash unit
-- Project    : SiLago
-------------------------------------------------------------------------------
-- File       : offset_gen.vhd
-- Author     : Guido Baccelli
-- Company    : KTH
-- Created    : 09/01/2019
-- Last update: 09/01/2019
-- Platform   : SiLago
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Contact    : Dimitrios Stathis <stathis@kth.se>
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 09/01/2019  1.0      Guido Baccelli      Created
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
--! Default working library
LIBRARY work;
--! Standard logic package
USE ieee.std_logic_1164.ALL;
--! Standard numeric package for signed and unsigned
USE ieee.numeric_std.ALL;

--! Offset generator for PWL implementation of Sigmoid and Hyperbolic Tangent

--! This module generates all offset values to compute PWL for Sigmoid and Tanh.
--! There are four distinct cases that require different offset values.
--! The PWL Look-up Table provides the offset for Sigmoid with positive inputs,
--! then this module derives the remaining three: Sigmoid negative inputs, Tanh positive inputs
--! and Tanh negative inputs. 
ENTITY offset_gen IS
  GENERIC (
    Nb            : INTEGER; --! Number of bits
    frac_part_lut : INTEGER  --! Number of fractional bits
  );
  PORT (
    offset_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --! Offset selector
    offset_in  : IN signed(Nb - 1 DOWNTO 0);      --! Input initial offset from LUT
    offset_out : OUT signed(Nb - 1 DOWNTO 0)      --! Output final offset
  );
END ENTITY;

--! @brief Behavioral description of PWL Offset generator for Sigmoid and Tanh
--! @details The offsets for Sigmoid positive inputs are fully contained in [0.5, 1] by construction.
--! This allows for a very cheap implementation of the required operations, that are:
--! \verbatim
--! CASE 00: offset , input >= 0 , sigmoid
--! CASE 01: 2*offset-1 , input >= 0 , TANHYP
--! CASE 10: 1-offset, input < 0 , sigmoid
--! CASE 11: 1-2*offset, input < 0 , TANHYP
--! \endverbatim
ARCHITECTURE bhv OF offset_gen IS

  --! Number of integer bits of LUT Q format
  CONSTANT int_part_lut                                             : INTEGER := Nb - frac_part_lut;

  SIGNAL offset_2x_minus_one, one_minus_offset, one_minus_offset_2x : signed(Nb - 1 DOWNTO 0);
BEGIN

  -- ######################################################################################

  --! Combinatorial process that generates offset
  offset_gen_proc : PROCESS (offset_in)
    VARIABLE temp_var                     : signed(Nb - 1 DOWNTO 0);
    VARIABLE offset2x                     : signed(Nb - 1 DOWNTO 0);
    VARIABLE minus_offset, minus_offset2x : signed(Nb - 1 DOWNTO 0);

  BEGIN
    minus_offset                              := - signed(offset_in);
    minus_offset2x                            := minus_offset(Nb - 1) & shift_left(minus_offset(Nb - 2 DOWNTO 0), 1);
    offset2x                                  := offset_in(Nb - 1) & shift_left(signed(offset_in(Nb - 2 DOWNTO 0)), 1);

    -- CASE "00": offset, input >= 0, Sigmoid
    -- No changes to input

    --! CASE "01": 2*offset-1, input >= 0, TANH
    temp_var(frac_part_lut - 1 DOWNTO 0)      := (offset2x(frac_part_lut - 1 DOWNTO 0)); --  fractional part
    temp_var(Nb - 1 DOWNTO Nb - int_part_lut) := (OTHERS => '0');
    temp_var(Nb - int_part_lut)               := offset2x(Nb - int_part_lut + 1); -- integer part
    offset_2x_minus_one <= temp_var;

    --! CASE "10": 1-offset, input < 0 , Sigmoid
    temp_var                             := (OTHERS => '0');                          -- integer part
    temp_var(frac_part_lut - 1 DOWNTO 0) := minus_offset(frac_part_lut - 1 DOWNTO 0); -- fractional part
    one_minus_offset <= temp_var;

    --! CASE "11": 1-2*offset, input < 0, TANH
    temp_var                                  := minus_offset2x;
    temp_var(Nb - 1 DOWNTO Nb - int_part_lut) := (OTHERS => NOT(minus_offset2x(Nb - int_part_lut))); -- integer part
    one_minus_offset_2x <= temp_var;

  END PROCESS;

  --! Selection of correct offset to output
  offset_selection_proc : PROCESS (offset_sel, offset_in, offset_2x_minus_one, one_minus_offset, one_minus_offset_2x)
    VARIABLE offset_var : signed(Nb - 1 DOWNTO 0);
  BEGIN
    CASE offset_sel IS
      WHEN "00" =>
        offset_var := signed(offset_in);
      WHEN "01" =>
        offset_var := offset_2x_minus_one;
      WHEN "10" =>
        offset_var := one_minus_offset;
      WHEN OTHERS => -- "11"
        offset_var := one_minus_offset_2x;
    END CASE;
    offset_out <= offset_var;
  END PROCESS;

END ARCHITECTURE;