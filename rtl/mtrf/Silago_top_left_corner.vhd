-------------------------------------------------------
--! @file Silago_top_left_corner.vhd
--! @brief SiLago top left corner
--! @details Similar to Silago_top.vhd
--! @author Dimitrios Stathis
--! @version 1.0
--! @date 2020-02-11
--! @bug NONE
--! @todo NONE
--! @copyright  GNU Public License [GPL-3.0].
-------------------------------------------------------
---------------- Copyright (c) notice -----------------------------------------
--
-- The VHDL code, the logic and concepts described in this file constitute
-- the intellectual property of the authors listed below, who are affiliated
-- to KTH(Kungliga Tekniska Högskolan), School of ICT, Kista.
-- Any unauthorised use, copy or distribution is strictly prohibited.
-- Any authorised use, copy or distribution should carry this copyright notice
-- unaltered.
-------------------------------------------------------------------------------
-- Title      : SiLago top left corner
-- Project    : SiLago
-------------------------------------------------------------------------------
-- File       : Silago_top_left_corner.vhd
-- Author     : Dimitrios Stathis
-- Company    : KTH
-- Created    : 15/01/2018
-- Last update: 2022-04-13
-- Platform   : SiLago
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Copyright (c) 2018
-------------------------------------------------------------------------------
-- Contact    : Dimitrios Stathis <stathis@kth.se>
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 15/01/2018  1.0      Dimitrios Stathis       Created
-- 2020-02-11  2.0      Dimitrios Stathis       Add immediate signal propagation for shadow register
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.seq_functions_package.ALL;
USE work.util_package.ALL;
USE work.top_consts_types_package.ALL;
USE work.noc_types_n_constants.NOC_BUS_TYPE;
USE work.noc_types_n_constants.DATA_IO_SIGNAL_TYPE;
USE work.noc_types_n_constants.ROW_WIDTH;
USE work.noc_types_n_constants.COL_WIDTH;

--! This is the DRRA top tile for the first column (corner case).

--! This is a copy of the normal top tile, for helping with the physical synthesis.
--! It is the combination of all the components
--! That are needed to connect the DRRA fabric. It is stand-alone (can be harden)
--! and has dynamic addressing
--! Includes the following:
--! \verbatim
--! Address assignment unit
--! Data selector, selects which row will have access to the DiMArch that is connected to this row
--! DRRA silego cell  
--! \endverbatim
ENTITY Silago_top_left_corner IS
--  generic(
--    ROW_WIDTH : integer := 1;         --! Addressing bits for row
--    COL_WIDTH : integer := 5          --! Addressing bits for col
-- DIMARCH_PIPELINE_ENABLE : integer := 1  --! If 1, pipeline between dimarch and bottom drra cell is inserted
--  );
    PORT (
        clk   : IN std_logic;
        rst_n : IN std_logic;
        ----------------------------------------------------
        -- REV 2 2020-02-11 --------------------------------
        ----------------------------------------------------
        -- Removed, only needed for synchoros synthesis
        -------------------------
        -- Pass-through clock and reset signals
        -------------------------
        -- clk_input  : IN std_logic;  --! Propagation signal clk input -- Placed
        -- rst_input  : IN std_logic;  --! Propagation signal rst input -- Placed
        -- rst_output : OUT std_logic; --! Propagation signal rst output
        -- clk_output : OUT std_logic; --! Propagation signal clk output
        --------------------------------------------------------------------------------
        immediate : IN std_logic;
        ----------------------------------------------------
        -- End of modification REV 2 -----------------------
        ----------------------------------------------------

        -------------------------
        -- Address signals
        -------------------------
        --start                        : in  std_logic; --! Start signal (connected to the valid signal of the previous block in the same row)
        --		start_col                    : in  std_logic; --! Start signal (connected to the valid signal of the previous block in the same col)
        --		prevRow                      : in  UNSIGNED(ROW_WIDTH - 1 DOWNTO 0); --! Row address assigned to the previous cell
        --		prevCol                      : in  UNSIGNED(COL_WIDTH - 1 DOWNTO 0); --! Col address assigned to the previous cell

        valid_top   : OUT std_logic;                        --! Valid signals, used to signal that the assignment of the address is complete
        thisRow_top : OUT UNSIGNED(ROW_WIDTH - 1 DOWNTO 0); --! The row address assigned to the cell
        thisCol_top : OUT UNSIGNED(COL_WIDTH - 1 DOWNTO 0); --! The column address assigned to the cell

        valid_right   : OUT std_logic;                        --! Valid signals, used to signal that the assignment of the address is complete
        thisRow_right : OUT UNSIGNED(ROW_WIDTH - 1 DOWNTO 0); --! The row address assigned to the cell
        thisCol_right : OUT UNSIGNED(COL_WIDTH - 1 DOWNTO 0); --! The column address assigned to the cell

        valid_bot   : OUT std_logic;                        --! Copy of the valid signal, connection to the bottom row
        thisRow_bot : OUT UNSIGNED(ROW_WIDTH - 1 DOWNTO 0); --! Copy of the row signal, connection to the bottom row
        thisCol_bot : OUT UNSIGNED(COL_WIDTH - 1 DOWNTO 0); --! Copy of the col signal, connection to the bottom row
        ------------------------------
        -- Data in (from next row)
        ------------------------------
        data_in_next               : IN STD_LOGIC_VECTOR(SRAM_WIDTH - 1 DOWNTO 0); --! data from other row
        dimarch_silego_rd_out_next : IN std_logic;                                 --! ready signal from the other row

        ------------------------------
        -- Data out to DiMArch
        ------------------------------
        dimarch_data_in_out : OUT STD_LOGIC_VECTOR(SRAM_WIDTH - 1 DOWNTO 0); --! data from DiMArch to the next row

        ------------------------------
        -- Global signals for configuration
        ------------------------------
        -- inputs (left hand side)
        instr_ld       : IN std_logic;                                  --! load instruction signal
        instr_inp      : IN std_logic_vector(INSTR_WIDTH - 1 DOWNTO 0); --! Actual instruction to be loaded
        seq_address_rb : IN std_logic_vector(ROWS - 1 DOWNTO 0);        --! in order to generate addresses for sequencer rows
        seq_address_cb : IN std_logic_vector(COLUMNS - 1 DOWNTO 0);     --! in order to generate addresses for sequencer cols
        -- outputs (right hand side)
        instr_ld_out_right       : OUT std_logic;                                  --! Registered instruction load signal, broadcast to the next cell
        instr_inp_out_right      : OUT std_logic_vector(INSTR_WIDTH - 1 DOWNTO 0); --! Registered instruction signal, bradcast to the next cell
        seq_address_rb_out_right : OUT std_logic_vector(ROWS - 1 DOWNTO 0);        --! registered signal, broadcast to the next cell, in order to generate addresses for sequencer rows
        seq_address_cb_out_right : OUT std_logic_vector(COLUMNS - 1 DOWNTO 0);     --! registed signal, broadcast to the next cell, in order to generate addresses for sequencer cols

        instr_ld_out_bot       : OUT std_logic;                                  --! Registered instruction load signal, broadcast to the next cell
        instr_inp_out_bot      : OUT std_logic_vector(INSTR_WIDTH - 1 DOWNTO 0); --! Registered instruction signal, bradcast to the next cell
        seq_address_rb_out_bot : OUT std_logic_vector(ROWS - 1 DOWNTO 0);        --! registered signal, broadcast to the next cell, in order to generate addresses for sequencer rows
        seq_address_cb_out_bot : OUT std_logic_vector(COLUMNS - 1 DOWNTO 0);     --! registed signal, broadcast to the next cell, in order to generate addresses for sequencer cols
        ------------------------------
        -- Silego core cell
        ------------------------------
        --RegFile
        -- Data transfer only allowed through the dimarch
        dimarch_data_in  : IN STD_LOGIC_VECTOR(SRAM_WIDTH - 1 DOWNTO 0);  --! data from dimarch (top)
        dimarch_data_out : OUT STD_LOGIC_VECTOR(SRAM_WIDTH - 1 DOWNTO 0); --! data out to dimarch (top)
        ------------------------------
        -- DiMArch bus output
        ------------------------------
        noc_bus_out : OUT NOC_BUS_TYPE; --! noc bus signal to the dimarch (top)
        ------------------------------
        -- NoC bus from the next row to the DiMArch
        ------------------------------
        -- TODO we can move the noc bus selector from the DiMArch to the cell in order to save some routing
        noc_bus_in : IN NOC_BUS_TYPE; --! noc bus signal from the adjacent row (bottom)
        ------------------------------
        --Horizontal Busses
        ------------------------------
        ---------------------------------------------------------------------------------------
        -- Modified by Dimitris to remove inputs and outputs that are not connected (left hand side)
        -- Date 15/03/2018
        ---------------------------------------------------------------------------------------
        --h_bus_reg_in_out0_0_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_reg_in_out0_1_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_in_out0_3_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_in_out0_4_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out0_0_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out0_1_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out0_3_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out0_4_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_reg_in_out1_0_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_reg_in_out1_1_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_in_out1_3_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_in_out1_4_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out1_0_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out1_1_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out1_3_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_reg_out_out1_4_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_dpu_in_out0_0_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_dpu_in_out0_1_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_in_out0_3_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_in_out0_4_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out0_0_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out0_1_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out0_3_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out0_4_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_dpu_in_out1_0_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        --h_bus_dpu_in_out1_1_left     : IN  signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_in_out1_3_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_in_out1_4_right  : IN signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out1_0_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out1_1_right : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out1_3_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        h_bus_dpu_out_out1_4_left  : OUT signed(BITWIDTH - 1 DOWNTO 0);
        --sel_r_ext_in               : IN  s_bus_switchbox_ty;
        sel_r_ext_in_0 : IN std_logic_vector(5 DOWNTO 0);
        sel_r_ext_in_1 : IN std_logic_vector(5 DOWNTO 0);
        sel_r_ext_in_2 : IN std_logic_vector(5 DOWNTO 0);
        sel_r_ext_in_3 : IN std_logic_vector(5 DOWNTO 0);
        sel_r_ext_in_4 : IN std_logic_vector(5 DOWNTO 0);
        sel_r_ext_in_5 : IN std_logic_vector(5 DOWNTO 0);
        --ext_v_input_bus_in         : IN  v_bus_ty;
        ext_v_input_bus_in_0 : IN signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_in_1 : IN signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_in_2 : IN signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_in_3 : IN signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_in_4 : IN signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_in_5 : IN signed(BITWIDTH - 1 DOWNTO 0);
        --sel_r_ext_out              : OUT s_bus_switchbox_ty;
        sel_r_ext_out_0 : OUT std_logic_vector(5 DOWNTO 0);
        sel_r_ext_out_1 : OUT std_logic_vector(5 DOWNTO 0);
        sel_r_ext_out_2 : OUT std_logic_vector(5 DOWNTO 0);
        sel_r_ext_out_3 : OUT std_logic_vector(5 DOWNTO 0);
        sel_r_ext_out_4 : OUT std_logic_vector(5 DOWNTO 0);
        sel_r_ext_out_5 : OUT std_logic_vector(5 DOWNTO 0);
        --ext_v_input_bus_out        : OUT v_bus_ty
        ext_v_input_bus_out_0 : OUT signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_out_1 : OUT signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_out_2 : OUT signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_out_3 : OUT signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_out_4 : OUT signed(BITWIDTH - 1 DOWNTO 0);
        ext_v_input_bus_out_5 : OUT signed(BITWIDTH - 1 DOWNTO 0)
    );
END ENTITY Silago_top_left_corner;

--! @brief Structural architecture of the tile.
--! @details The structure of the module can be seen here:
--! \image html DRRA_top.png "DRRA top row cells"
--! Includes the following:
--! \verbatim
--! Address assignment unit
--! data selector  
--! SiLago core cell
--! \endverbatim
--! All configuration wires in these version are pipeline. Data load and store 
--! can only take place from and to the DiMArch, and not with outside of the fabric
ARCHITECTURE RTL OF Silago_top_left_corner IS
    SIGNAL data_in_this               : STD_LOGIC_VECTOR(SRAM_WIDTH - 1 DOWNTO 0); --! data from this cell
    SIGNAL dimarch_silego_rd_out_this : std_logic;                                 --! ready signal from this cell
    SIGNAL noc_bus_out_this           : NOC_BUS_TYPE;
    -------------------------
    -- configuration signals
    -------------------------
    SIGNAL instr_ld_out       : std_logic;                                  --! Registered instruction load signal, broadcast to the next cell
    SIGNAL instr_inp_out      : std_logic_vector(INSTR_WIDTH - 1 DOWNTO 0); --! Registered instruction signal, bradcast to the next cell
    SIGNAL seq_address_rb_out : std_logic_vector(ROWS - 1 DOWNTO 0);        --! registered signal, broadcast to the next cell, in order to generate addresses for sequencer rows
    SIGNAL seq_address_cb_out : std_logic_vector(COLUMNS - 1 DOWNTO 0);     --! registed signal, broadcast to the next cell, in order to generate addresses for sequencer col
    -------------------------
    -- Address signals
    -------------------------
    SIGNAL zero_row, this_row : unsigned(ROW_WIDTH - 1 DOWNTO 0);
    SIGNAL zero_col, this_col : unsigned(COL_WIDTH - 1 DOWNTO 0);
    SIGNAL valid              : std_logic;

    SIGNAL seq_address_rb_sig : std_logic; --! temporary signal that holds the value of the hot bit
    SIGNAL seq_address_cb_sig : std_logic; --! temporary signal that holds the value of the hot bit

    ----------------------------------------------------
    -- REV 2 2020-02-11 --------------------------------
    ----------------------------------------------------
    --    COMPONENT buffer_name
    --        PORT (
    --            I : IN std_logic;
    --            Z : OUT std_logic);
    --    END COMPONENT;
    ----------------------------------------------------
    -- End of modification REV 2 -----------------------
    ----------------------------------------------------
BEGIN
    ----------------------------------------------------
    -- REV 2 2020-02-11 --------------------------------
    ----------------------------------------------------

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- propagation of clock and reset
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- technology depended
    -- rst_BUFF    : buffer_name PORT MAP(I => rst_input, Z => rst_output);
    -- clk_and_mux : buffer_name PORT MAP(I => clk_input, Z => clk_output);
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Data selector
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ----------------------------------------------------
    -- End of modification REV 2 -----------------------
    ----------------------------------------------------
    --TODO A new type of configuration is required, more efficient and through the dimarch
    register_transfer_global : PROCESS (clk, rst_n) IS
    BEGIN
        IF rst_n = '0' THEN
            instr_ld_out       <= '0';
            instr_inp_out      <= (OTHERS => '0');
            seq_address_rb_out <= (OTHERS => '0');
            seq_address_cb_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            instr_ld_out       <= instr_ld;
            instr_inp_out      <= instr_inp;
            seq_address_rb_out <= seq_address_rb;
            seq_address_cb_out <= seq_address_cb;
        END IF;
    END PROCESS register_transfer_global;

    instr_ld_out_right       <= instr_ld_out;
    instr_inp_out_right      <= instr_inp_out;
    seq_address_rb_out_right <= seq_address_rb_out;
    seq_address_cb_out_right <= seq_address_cb_out;

    instr_ld_out_bot       <= instr_ld_out;
    instr_inp_out_bot      <= instr_inp_out;
    seq_address_rb_out_bot <= seq_address_rb_out;
    seq_address_cb_out_bot <= seq_address_cb_out;
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Data selector
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    u_data_selector : ENTITY work.data_selector
        PORT MAP(
            data_in_this                 => data_in_this,               -- data from this cell
            data_in_next                 => data_in_next,               -- data from the adjacent cell
            data_out                     => dimarch_data_out,           -- output to the DiMArch
            dimarch_silego_rd_2_out_this => dimarch_silego_rd_out_this, -- ready signal from this cell
            dimarch_silego_rd_out_next   => dimarch_silego_rd_out_next  -- ready signal for the adjacent cell
        );
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Noc Bus selector
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    u_bus_selector : ENTITY work.bus_selector
        PORT MAP(
            noc_bus_in0 => noc_bus_out_this,
            noc_bus_in1 => noc_bus_in,
            noc_bus_out => noc_bus_out
        );
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Connection to the adjacent row
    -- dimarch_pipe: if DIMARCH_PIPELINE_ENABLE = 1 generate
      dimarch_data_pipe : PROCESS (clk, rst_n)
      BEGIN
        IF rst_n = '0' THEN
          dimarch_data_in_out <= (OTHERS => '0'); -- propagate the DiMArch data to the adjacent row
        ELSIF rising_edge(clk) THEN
          dimarch_data_in_out <= dimarch_data_in; -- propagate the DiMArch data to the adjacent row
        END IF;
      END PROCESS;
--    end generate;
--    dimarch_no_pipe: if DIMARCH_PIPELINE_ENABLE = 0 generate
--      dimarch_data_in_out <= dimarch_data_in;
--    end generate;
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- Address assignment unit
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- First assignment of the address. in this case we do not use the
    -- normal unit since it is the first cell
    u_addres_assign : ENTITY work.addr_assign_drra_top_l_corner(RTL_first_cell)
        PORT MAP(
            clk       => clk,
            rst_n     => rst_n,
            start_row => '1', -- Start row is used to input the valid signal from the fabric 
            start_col => '0',
            prevRow   => zero_row,
            prevCol   => zero_col,
            valid     => valid,
            thisRow   => this_row,
            thisCol   => this_col
        );

    thisRow_top   <= this_row;
    thisRow_right <= this_row;
    thisRow_bot   <= this_row;

    thisCol_top   <= this_col;
    thisCol_right <= this_col;
    thisCol_bot   <= this_col;

    valid_top   <= valid;
    valid_right <= valid;
    valid_bot   <= valid;

    seq_address_rb_sig <= seq_address_rb(to_integer(this_row));
    seq_address_cb_sig <= seq_address_cb(to_integer(this_col));

    -- Silego core cell
    SILEGO_cell : ENTITY work.silego
        PORT MAP(
            ----------------------------------------------------
            -- REV 2 2020-02-11 --------------------------------
            ----------------------------------------------------
            immediate => immediate,
            ----------------------------------------------------
            -- End of modification REV 2 -----------------------
            ----------------------------------------------------
            dimarch_data_in  => dimarch_data_in,
            dimarch_data_out => data_in_this,
            dimarch_rd_2_out => dimarch_silego_rd_out_this,
            noc_bus_out      => noc_bus_out_this,
            clk              => clk,
            rst_n            => rst_n,
            instr_ld         => instr_ld,  --(i),                                                                                       
            instr_inp        => instr_inp, --instr_output(i)(OLD_INSTR_WIDTH-1 downto INSTR_WIDTH_DIFF),                  
            --seq_address 			                                                        
            seq_address_rb => seq_address_rb_sig,
            seq_address_cb => seq_address_cb_sig,

            --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            --Horizontal Busses
            --------------------------------------------------------------------------
            -- Remove unneeded connections (left hand side)
            -- Outputs removed, inputs set to 0
            -- Dimitris 15/03/2018
            --------------------------------------------------------------------------
            h_bus_reg_in_out0_0_left => (OTHERS => '0'), -- h_bus_reg_seg_0(i+1,0) ,
            h_bus_reg_in_out0_1_left => (OTHERS => '0'), --h_bus_reg_seg_0(i+1,1),
            h_bus_reg_in_out0_3_right  => h_bus_reg_in_out0_3_right,
            h_bus_reg_in_out0_4_right  => h_bus_reg_in_out0_4_right,
            h_bus_reg_out_out0_0_right => h_bus_reg_out_out0_0_right,
            h_bus_reg_out_out0_1_right => h_bus_reg_out_out0_1_right,
            h_bus_reg_out_out0_3_left  => h_bus_reg_out_out0_3_left,
            h_bus_reg_out_out0_4_left  => h_bus_reg_out_out0_4_left,
            --------------------------------------------------------------------------
            h_bus_reg_in_out1_0_left => (OTHERS => '0'),
            h_bus_reg_in_out1_1_left => (OTHERS => '0'),
            h_bus_reg_in_out1_3_right  => h_bus_reg_in_out1_3_right,
            h_bus_reg_in_out1_4_right  => h_bus_reg_in_out1_4_right,
            h_bus_reg_out_out1_0_right => h_bus_reg_out_out1_0_right,
            h_bus_reg_out_out1_1_right => h_bus_reg_out_out1_1_right,
            h_bus_reg_out_out1_3_left  => h_bus_reg_out_out1_3_left,
            h_bus_reg_out_out1_4_left  => h_bus_reg_out_out1_4_left,
            --------------------------------------------------------------------------
            h_bus_dpu_in_out0_0_left => (OTHERS => '0'),
            h_bus_dpu_in_out0_1_left => (OTHERS => '0'),
            h_bus_dpu_in_out0_3_right  => h_bus_dpu_in_out0_3_right,
            h_bus_dpu_in_out0_4_right  => h_bus_dpu_in_out0_4_right,
            h_bus_dpu_out_out0_0_right => h_bus_dpu_out_out0_0_right,
            h_bus_dpu_out_out0_1_right => h_bus_dpu_out_out0_1_right,
            h_bus_dpu_out_out0_3_left  => h_bus_dpu_out_out0_3_left,
            h_bus_dpu_out_out0_4_left  => h_bus_dpu_out_out0_4_left,
            --------------------------------------------------------------------------
            h_bus_dpu_in_out1_0_left => (OTHERS => '0'),
            h_bus_dpu_in_out1_1_left => (OTHERS => '0'),
            h_bus_dpu_in_out1_3_right  => h_bus_dpu_in_out1_3_right,
            h_bus_dpu_in_out1_4_right  => h_bus_dpu_in_out1_4_right,
            h_bus_dpu_out_out1_0_right => h_bus_dpu_out_out1_0_right,
            h_bus_dpu_out_out1_1_right => h_bus_dpu_out_out1_1_right,
            h_bus_dpu_out_out1_3_left  => h_bus_dpu_out_out1_3_left,
            h_bus_dpu_out_out1_4_left  => h_bus_dpu_out_out1_4_left,
            --------------------------------------------------------------------------
            --Vertical Busses
            --sel_r_ext_in               
            sel_r_ext_in_0 => sel_r_ext_in_0,
            sel_r_ext_in_1 => sel_r_ext_in_1,
            sel_r_ext_in_2 => sel_r_ext_in_2,
            sel_r_ext_in_3 => sel_r_ext_in_3,
            sel_r_ext_in_4 => sel_r_ext_in_4,
            sel_r_ext_in_5 => sel_r_ext_in_5,
            --ext_v_input_bus_in        =>    
            ext_v_input_bus_in_0 => ext_v_input_bus_in_0,
            ext_v_input_bus_in_1 => ext_v_input_bus_in_1,
            ext_v_input_bus_in_2 => ext_v_input_bus_in_2,
            ext_v_input_bus_in_3 => ext_v_input_bus_in_3,
            ext_v_input_bus_in_4 => ext_v_input_bus_in_4,
            ext_v_input_bus_in_5 => ext_v_input_bus_in_5,
            --sel_r_ext_out             =>--sel_r_ext_out,
            sel_r_ext_out_0 => sel_r_ext_out_0,
            sel_r_ext_out_1 => sel_r_ext_out_1,
            sel_r_ext_out_2 => sel_r_ext_out_2,
            sel_r_ext_out_3 => sel_r_ext_out_3,
            sel_r_ext_out_4 => sel_r_ext_out_4,
            sel_r_ext_out_5 => sel_r_ext_out_5,
            --ext_v_input_bus_out       =>--ext_v_input_bus_out,
            ext_v_input_bus_out_0 => ext_v_input_bus_out_0,
            ext_v_input_bus_out_1 => ext_v_input_bus_out_1,
            ext_v_input_bus_out_2 => ext_v_input_bus_out_2,
            ext_v_input_bus_out_3 => ext_v_input_bus_out_3,
            ext_v_input_bus_out_4 => ext_v_input_bus_out_4,
            ext_v_input_bus_out_5 => ext_v_input_bus_out_5
        );

END ARCHITECTURE RTL;
