function DEO:GetSpec()
	_, DEOPlayerClass = UnitClass("player")
	DEOPlayerSpec = GetSpecialization() --nil if under level 10
  DEO:Print(ChatFrame4,DEOPlayerClass, DEOPlayerSpec)
end