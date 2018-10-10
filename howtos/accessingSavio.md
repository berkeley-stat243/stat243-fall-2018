# Login to Savio

Follow [these instructions](http://research-it.berkeley.edu/services/high-performance-computing/logging-brc-clusters) to set up the ability to login to your account. You only need to do this once. You'll need the Google authenticator app on your phone or the Authy app on your laptop.

Each time you login, you'll need to login to `hpc.brc.berkeley.edu`, enter the login name that Chris provided and then enter `XXXXXXYYYYYY` as your password, where `XXXXXX` is your PIN and `YYYYYY` is the one-time password provided on the Google authentiator app.

# Remote Desktop (GUI-based applications)

See the instructions for accessing the [Savio viz node](https://research-it.berkeley.edu/services/high-performance-computing/using-brc-visualization-node-realvnc). You'll need the VNCViewer Chrome plug-in or a VNC viewer application on your computer.

Make sure you are NOT using the CalVisitor wireless when you do this.

To start a browser in the remote desktop run `/global/scratch/kmuriki/firefox`.

To access the Spark UI, go to `http://n0070.savio2:8080` (replace 'n0070.savio2' with the name of the node that your Spark job is running on.
