""" openfactory-sdk asset inspect command. """

import click
from rich import box
from rich.console import Console
from rich.table import Table
from openfactory.assets import Asset
from openfactory.ofa.ksqldb import ksql


@click.command(name='inspect')
@click.argument('asset_uuid', type=click.STRING)
def click_inspect(asset_uuid: str) -> None:
    """ List all attributes from an asset. """

    console = Console()
    table = Table(
        title=asset_uuid,
        title_justify="left",
        box=box.HORIZONTALS,
        show_lines=True)

    table.add_column("ID", style="cyan", no_wrap=True)
    table.add_column("Value", justify="left")
    table.add_column("Type", justify="left")
    table.add_column("Tag", justify="left")

    asset = Asset(asset_uuid, ksqlClient=ksql.client)

    samples = asset.samples()
    for sample in samples:
        table.add_row(sample['ID'],
                      sample['VALUE'],
                      'Sample',
                      sample['TAG'])

    events = asset.events()
    for event in events:
        table.add_row(event['ID'],
                      event['VALUE'],
                      'Events',
                      event['TAG'])

    conditions = asset.conditions()
    for cond in conditions:
        table.add_row(cond['ID'],
                      cond['VALUE'],
                      'Condition',
                      cond['TAG'])

    console.print(table)
