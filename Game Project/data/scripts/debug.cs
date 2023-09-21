using Godot;
using System;

public partial class debug : Control{
	[Export] public float test = 3f;
	
	[ExportNodePath]
    public NodePath Inimigo;

	public override void _Ready(){
	}

	public override void _Process(double delta){
		GD.Print("testing");
	}
}
