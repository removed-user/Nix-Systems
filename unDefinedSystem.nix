# An inherently "impure" process (command) to return the architecture
getArch = {
cmd = "uname -m";
};

getPlat = {
cmd = "uname -s";
};
