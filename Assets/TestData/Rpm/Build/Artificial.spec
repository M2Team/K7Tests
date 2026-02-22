Name:       Artificial
Version:    1.0
Release:    1
Summary:    K7Tests Test RPM
License:    https://corpus.canterbury.ac.nz
BuildArch:  noarch

Source0:    a.txt
Source1:    aaa.txt
Source2:    alphabet.txt
Source3:    random.txt

%description
This is a minimal package for use with K7Tests.

%install
cp %{SOURCE0} %{buildroot}/
cp %{SOURCE1} %{buildroot}/
cp %{SOURCE2} %{buildroot}/
cp %{SOURCE3} %{buildroot}/

%files
/a.txt
/aaa.txt
/alphabet.txt
/random.txt
