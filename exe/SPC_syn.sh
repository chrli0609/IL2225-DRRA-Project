wait_for_session_exit() {
    local session_name=$1

    while tmux has-session -t "$session_name" 2>/dev/null; do
        sleep 1
    done
}

for i in  {1..5}; do
	tmux new-session -d -s innovus_session_top 'innovus -stylus'
	tmux send-keys -t innovus_session_top 'cd ../phy/db/part/Silago_top_SPC_$i.enc.dat/' Enter
	tmux send-keys -t innovus_session_top -l 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t innovus_session_top -l 'exit' Enter
	wait_for_session_exit innovus_session_top
	
	tmux new-session -d -s innovus_session_bot 'innovus -stylus'
	tmux send-keys -t innovus_session_bot 'cd ../phy/db/part/Silago_bot_SPC_$i.enc.dat/' Enter
	tmux send-keys -t innovus_session_bot -l 'source ../../../scr/pnr_partition.tcl' Enter
	tmux send-keys -t innovus_session_bot -l 'exit' Enter
	wait_for_session_exit innovus_session_bot
done
