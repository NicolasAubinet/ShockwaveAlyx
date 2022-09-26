using System.Text;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Windows.Forms;

namespace ShockwaveAlyx
{
    public partial class Form1 : Form
    {
        private bool _parsingMode;
        private ShockwavePlayer _player = new();

        private delegate void SafeCallDelegate(string text);

        public Form1()
        {
            InitializeComponent();
        }

        public static IEnumerable<string> ReadLines(string path)
        {
            using (var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite, 0x1000, FileOptions.SequentialScan))
            using (var sr = new StreamReader(fs, Encoding.UTF8))
            {
                string line;
                while ((line = sr.ReadLine()) != null)
                {
                    yield return line;
                }
            }
        }

        private void WriteTextSafe(string text)
        {
            if (lblInfo.InvokeRequired)
            {
                var d = new SafeCallDelegate(WriteTextSafe);
                lblInfo.Invoke(d, new object[] { text });
            }
            else
            {
                lblInfo.Text = text;
            }
        }

        void ParseLine(string line)
        {
            string newLine = line.Replace('{', ' ');
            newLine = newLine.Replace('}', ' ');
            newLine = newLine.Trim();

            string[] splitted = newLine.Split(new char[] {'|'});

            if (splitted.Length > 0)
            {
                string command = splitted[0].Trim();
                if (command == "PlayerHealth")
                {
                    if (splitted.Length > 1)
                    {
                        int health = int.Parse(splitted[1].Trim());
                        if (health >= 0)
                        {
                            _player.HealthRemaining(health);
                        }
                    }
                }
                else if (command == "PlayerHurt")
                {
                    if (splitted.Length > 1)
                    {
                        int healthRemaining = int.Parse(splitted[1].Trim());
                        string enemy = "";
                        float playerAngle = 0;
                        string enemyName = "";
                        string enemyDebugName = "";

                        if (splitted.Length > 2)
                        {
                            enemy = splitted[2].Trim();
                        }

                        if (splitted.Length > 3)
                        {
                            playerAngle = float.Parse(splitted[3].Trim());
                        }
                        if (splitted.Length > 4)
                        {
                            enemyName = (splitted[4].Trim());
                        }
                        if (splitted.Length > 5)
                        {
                            enemyDebugName = (splitted[5].Trim());
                        }

                        _player.PlayerHurt(healthRemaining, enemy, playerAngle, enemyName, enemyDebugName);
                    }
                }
                else if (command == "PlayerShootWeapon")
                {
                    if (splitted.Length > 1)
                    {
                        _player.PlayerShoot(splitted[1].Trim());
                    }
                }
                else if (command == "TwoHandStart")
                {
                    _player.TwoHandedMode = true;
                }
                else if (command == "TwoHandEnd")
                {
                    _player.TwoHandedMode = false;
                }
                else if (command == "PlayerOpenedGameMenu")
                {
                    _player.MenuOpen = true;
                }
                else if (command == "PlayerClosedGameMenu")
                {
                    _player.MenuOpen = false;
                }
                else if (command == "PlayerShotgunUpgradeGrenadeLauncherState")
                {
                    if (splitted.Length > 1)
                    {
                        int state = int.Parse(splitted[1].Trim());

                        _player.GrenadeLauncherStateChange(state);
                    }
                }
                else if (command == "PlayerGrabbityLockStart")
                {
                    if (splitted.Length > 1)
                    {
                        int primary = int.Parse(splitted[1].Trim());

                        _player.GrabbityLockStart(primary == 1);
                    }
                }
                else if (command == "PlayerGrabbityLockStop")
                {
                    if (splitted.Length > 1)
                    {
                        int primary = int.Parse(splitted[1].Trim());

                        _player.GrabbityLockStop(primary == 1);
                    }
                }
                else if (command == "PlayerGrabbityPull")
                {
                    if (splitted.Length > 1)
                    {
                        int primary = int.Parse(splitted[1].Trim());

                        _player.GrabbityGlovePull(primary == 1);
                    }
                }
                else if (command == "PlayerGrabbedByBarnacle")
                {
                    _player.BarnacleGrabStart();
                }
                else if (command == "PlayerReleasedByBarnacle")
                {
                    _player.BarnacleGrab = false;
                }
                else if (command == "PlayerDeath")
                {
                    if (splitted.Length > 1)
                    {
                        int damagebits = int.Parse(splitted[1].Trim());

                        _player.PlayerDeath(damagebits);
                    }
                }
                else if (command == "Reset")
                {
                    _player.Reset();
                }
                else if (command == "PlayerCoughStart")
                {
                    _player.Cough();
                }
                else if (command == "PlayerCoughEnd")
                {
                    _player.Coughing = false;
                }
                else if (command == "PlayerCoveredMouth")
                {
                    _player.Coughing = false;
                }
                else if (command == "GrabbityGloveCatch")
                {
                    if (splitted.Length > 1)
                    {
                        int primary = int.Parse(splitted[1].Trim());

                        _player.GrabbityGloveCatch(primary == 1);
                    }
                }
                else if (command == "PlayerDropAmmoInBackpack")
                {
                    if (splitted.Length > 1)
                    {
                        int leftShoulder = int.Parse(splitted[1].Trim());
                        _player.DropAmmoInBackpack(leftShoulder == 1);
                    }
                }
                else if (command == "PlayerDropResinInBackpack")
                {
                    if (splitted.Length > 1)
                    {
                        int leftShoulder = int.Parse(splitted[1].Trim());
                        _player.DropResinInBackpack(leftShoulder == 1);
                    }
                }
                else if (command == "PlayerRetrievedBackpackClip")
                {
                    if (splitted.Length > 1)
                    {
                        int leftShoulder = int.Parse(splitted[1].Trim());
                        _player.RetrievedBackpackClip(leftShoulder == 1);
                    }
                }
                else if (command == "PlayerStoredItemInItemholder"
                         || command == "HealthPenTeachStorage"
                         //|| command == "HealthVialTeachStorage"
                         )
                {
                    if (splitted.Length > 1)
                    {
                        int leftHolder = int.Parse(splitted[1].Trim());
                        _player.StoredItemInItemholder(leftHolder == 1);
                    }
                }
                else if (command == "PlayerRemovedItemFromItemholder")
                {
                    if (splitted.Length > 1)
                    {
                        int leftHolder = int.Parse(splitted[1].Trim());
                        _player.RemovedItemFromItemholder(leftHolder == 1);
                    }
                }
                else if (command == "PrimaryHandChanged" || command == "SingleControllerModeChanged")
                {
                    if (splitted.Length > 1)
                    {
                        int leftHanded = int.Parse(splitted[1].Trim());

                        _player.LeftHandedMode = leftHanded == 1;
                    }
                }
                else if (command == "PlayerHeal")
                {
                    float angle = 0;
                    if (splitted.Length > 1)
                    {
                        angle = float.Parse(splitted[1].Trim());
                    }
                    _player.HealthPenUse(angle);
                }
                else if (command == "PlayerUsingHealthstation")
                {
                    if (splitted.Length > 1)
                    {
                        int leftArm = int.Parse(splitted[1].Trim());
                        _player.HealthStationUse(leftArm == 1);
                    }
                }
                else if (command == "ItemPickup")
                {
                    if (splitted.Length > 1)
                    {
                        string item = splitted[1].Trim();

                        if (item == "item_hlvr_crafting_currency_large" || item == "item_hlvr_crafting_currency_small")
                        {
                            if (splitted.Length > 2)
                            {
                                int leftShoulder = int.Parse(splitted[2].Trim());
                                _player.RetrievedBackpackResin(leftShoulder == 1);
                            }
                        }
                    }
                }
                else if (command == "ItemReleased")
                {
                    if (splitted.Length > 1)
                    {
                        string item = splitted[1].Trim();

                        if (item == "item_hlvr_prop_battery")
                        {
                            if (splitted.Length > 2)
                            {
                                int leftArm = int.Parse(splitted[2].Trim());
                                _player.ShockOnArm(leftArm == 1);
                            }
                        }
                    }
                }
                else if (command == "PlayerPistolClipInserted" || command == "PlayerShotgunShellLoaded" || command == "PlayerRapidfireInsertedCapsuleInChamber" || command == "PlayerRapidfireInsertedCapsuleInMagazine")
                {
                    _player.ClipInserted();
                }
                else if (command == "PlayerPistolChamberedRound" || command == "PlayerShotgunLoadedShells" || command == "PlayerRapidfireClosedCasing" || command == "PlayerRapidfireOpenedCasing")
                {
                    _player.ChamberedRound();
                }
            }
            WriteTextSafe(line);

            GC.Collect();
        }

        void ParseConsole()
        {
            string filePath = txtAlyxDirectory.Text + "\\game\\hlvr\\console.log";

            bool first = true;
            int counter = 0;

            while (_parsingMode)
            {
                if (File.Exists(filePath))
                {
                    if (first)
                    {
                        first = false;
                        WriteTextSafe("Interface active");
                        counter = ReadLines(filePath).Count();
                    }
                    int lineCount = ReadLines(filePath).Count();//read text file line count to establish length for array

                    if (counter < lineCount && lineCount > 0)//if counter is less than lineCount keep reading lines
                    {
                        var lines = Enumerable.ToList(ReadLines(filePath).Skip(counter).Take(lineCount - counter));
                        for (int i = 0; i < lines.Count; i++)
                        {
                            if (lines[i].Contains("[Shockwave]"))
                            {
                                //Do haptic feedback
                                string line = lines[i].Substring(lines[i].LastIndexOf(']') + 1);
                                Thread thread = new Thread(() => ParseLine(line));
                                thread.Start();
                            }
                            else if (lines[i].Contains("unpaused the game"))
                            {
                                _player.MenuOpen = false;
                            }
                            else if (lines[i].Contains("paused the game"))
                            {
                                _player.MenuOpen = true;
                            }
                            else if (lines[i].Contains("Quitting"))
                            {
                                _player.Reset();
                            }
                        }

                        counter += lines.Count;
                    }
                    else if (counter == lineCount && lineCount > 0)
                    {
                        Thread.Sleep(50);
                    }
                    else
                    {
                        counter = 0;
                    }
                }
                else
                {
                    WriteTextSafe("Cannot file console.log. Waiting.");

                    Thread.Sleep(2000);
                }
            }
            WriteTextSafe("Waiting...");
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            string exePath = txtAlyxDirectory.Text + "\\game\\bin\\win64\\hlvr.exe";
            if (!File.Exists(exePath))
            {
                MessageBox.Show("Please select your Half-Life Alyx installation folder correctly first.", "Error Starting", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            string scriptPath = txtAlyxDirectory.Text + "\\game\\hlvr\\scripts\\vscripts\\shockwave.lua";
            if (!File.Exists(scriptPath))
            {
                MessageBox.Show("Script file installation is not correct. Please read the instructions on the mod page and reinstall.", "Script Installation Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            string scriptLoaderPath = txtAlyxDirectory.Text + "\\game\\hlvr\\cfg\\skill_manifest.cfg";
            string configText = File.ReadAllText(scriptLoaderPath);
            if (!configText.Contains("script_reload_code shockwave.lua"))
            {
                MessageBox.Show("skill_manifest.cfg file installation is not correct. Please read the instructions on the mod page and reinstall.", "Script Installation Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            btnStart.Enabled = false;
            btnStop.Enabled = true;
            btnBrowse.Enabled = false;
            btnTest.Enabled = true;

            WriteTextSafe("Starting...");

            _player.Connect();

            _parsingMode = true;

            Thread thread = new Thread(ParseConsole);
            thread.Start();
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            btnStart.Enabled = true;
            btnStop.Enabled = false;
            btnBrowse.Enabled = true;
            btnTest.Enabled = false;

            _parsingMode = false;

            _player.Disconnect();

            WriteTextSafe("Stopping...");
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog dialog = new FolderBrowserDialog();
            dialog.Description = "Select Half Life Alyx installation folder";
            dialog.ShowNewFolderButton = false;
            dialog.SelectedPath = "C:\\";
            if (dialog.ShowDialog() == DialogResult.OK)
            {
                txtAlyxDirectory.Text = dialog.SelectedPath;
                Properties.Settings.Default.AlyxDirectory = txtAlyxDirectory.Text;
                Properties.Settings.Default.Save();
            }
        }

        private void btnSettings_Click(object sender, EventArgs e)
        {
            // SettingsForm sForm = new SettingsForm(this);
            // sForm.Show();
            // btnSettings.Enabled = false;
        }

        private void btnTest_Click(object sender, EventArgs e)
        {
            _player.PlayTestHaptic();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            btnStart.Enabled = true;
            btnStop.Enabled = false;
            btnBrowse.Enabled = true;
            btnTest.Enabled = false;

            _parsingMode = false;

            WriteTextSafe("Stopping...");

            _player.Disconnect();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            txtAlyxDirectory.Text = Properties.Settings.Default.AlyxDirectory;
        }
    }
}