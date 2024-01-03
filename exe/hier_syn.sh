wait_for_session_exit() {
    local session_name=$1

    while tmux has-session -t "$session_name" 2>/dev/null; do
        sleep 1
    done
}

# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'source ../phy/scr/create_partitions.tcl' Enter
# tmux send-keys -t innovus_session 'exit' Enter

# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top_left_corner.enc.dat/' Enter
# tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
# tmux send-keys -t innovus_session 'exit' Enter
# wait_for_session_exit innovus_session
# 
# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot_left_corner.enc.dat/' Enter
# tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
# tmux send-keys -t innovus_session 'exit' Enter
# wait_for_session_exit innovus_session
# 
# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top.enc.dat/' Enter
# tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
# tmux send-keys -t innovus_session 'exit' Enter
# wait_for_session_exit innovus_session
# 
# tmux new-session -d -s innovus_session 'innovus -stylus'
# tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot.enc.dat/' Enter
# tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
# tmux send-keys -t innovus_session 'exit' Enter
# wait_for_session_exit innovus_session

for i in  {1..5}; do
	tmux new-session -d -s innovus_session_top 'innovus -stylus'
	tmux send-keys -t innovus_session_top "cd ../phy/db/part/Silago_top_SPC_$i.enc.dat/" Enter
	tmux send-keys -t innovus_session_top 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t innovus_session_top 'exit' Enter
	wait_for_session_exit innovus_session_top
	
	tmux new-session -d -s innovus_session_bot 'innovus -stylus'
	tmux send-keys -t innovus_session_bot "cd ../phy/db/part/Silago_bot_SPC_$i.enc.dat/" Enter
	tmux send-keys -t innovus_session_bot 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t innovus_session_bot 'exit' Enter
	wait_for_session_exit innovus_session_bot
done

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_top_right_corner.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter
wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'cd ../phy/db/part/Silago_bot_right_corner.enc.dat/' Enter
tmux send-keys -t innovus_session 'source ../../../scr/pnr_partition.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter
wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'source ../phy/scr/pnr_top.tcl' Enter
tmux send-keys -t innovus_session 'exit' Enter
wait_for_session_exit innovus_session

tmux new-session -d -s innovus_session 'innovus -stylus'
tmux send-keys -t innovus_session 'source ../phy/scr/assembly_design.tcl' Enter
