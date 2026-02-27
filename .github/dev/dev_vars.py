"""Generate dev.tfvars for workspace tests."""

from pathlib import Path

import typer

app = typer.Typer()

WORKSPACE_DIR = Path(__file__).parent.parent.parent / "tests" / "workspace_org_examples"
DEV_TFVARS = WORKSPACE_DIR / "dev.tfvars"


@app.command()
def org(existing_org_id: str = typer.Option(..., envvar="MONGODB_ATLAS_ORG_ID")) -> None:
    content = f'existing_org_id = "{existing_org_id}"\n'
    DEV_TFVARS.write_text(content)
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
