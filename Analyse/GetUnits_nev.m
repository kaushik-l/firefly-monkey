function units = GetUnits_nev(fname,getch)

load(fname);
units = units([units.chnl]==getch);