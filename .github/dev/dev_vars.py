# path-sync copy -n sdlc
"""Generate dev.tfvars for workspace tests."""

from pathlib import Path

import typer

app = typer.Typer()

WORKSPACE_DIR = Path(__file__).parent.parent.parent / "tests" / "workspace_org_examples"
DEV_TFVARS = WORKSPACE_DIR / "dev.tfvars"


@app.command()
def org(
    org_id: str = typer.Option(..., envvar="MONGODB_ATLAS_ORG_ID"),
    org_owner_id: str = typer.Option("", envvar="MONGODB_ATLAS_ORG_OWNER_ID"),
    org_name: str = typer.Option("", envvar="MONGODB_ATLAS_ORG_NAME"),
) -> None:
    """Generate dev.tfvars from environment variables."""
    WORKSPACE_DIR.mkdir(parents=True, exist_ok=True)
    lines = [f'org_id = "{org_id}"']
    if org_name:
        lines.append(f'org_name = "{org_name}"')
    else:
        typer.secho("MONGODB_ATLAS_ORG_NAME not set, import test will show name drift", fg="yellow")
    if org_owner_id:
        lines.append(f'org_owner_id = "{org_owner_id}"')
    else:
        typer.secho("MONGODB_ATLAS_ORG_OWNER_ID not set, org creation tests will be skipped", fg="yellow")
    DEV_TFVARS.write_text("\n".join(lines) + "\n")
    typer.echo(f"Generated {DEV_TFVARS}")


@app.command()
def tfrc(plugin_dir: str) -> None:
    """Print dev.tfrc content for provider dev_overrides."""
    content = f'''provider_installation {{
  dev_overrides {{
    "mongodb/mongodbatlas" = "{plugin_dir}"
  }}
  direct {{}}
}}
'''
    print(content, end="")


if __name__ == "__main__":
    app()
