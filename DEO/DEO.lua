function DEO:GetSpec()
	_, DEOPlayerClass = UnitClass("player")
	DEOPlayerSpec = GetSpecialization() --nil if under level 10
  DEO:Print(DEOPlayerClass, DEOPlayerSpec)
end