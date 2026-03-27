package org.apache.cassandra.cql3;

import org.junit.Test;

import org.apache.cassandra.cql3.statements.SelectStatement;
import org.apache.cassandra.cql3.transactions.SelectReferenceSource;
import org.apache.cassandra.schema.ColumnMetadata;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

public class SelectReferenceSourceTest extends CQLTester
{
    @Test
    public void testGetColumnResolvesAliasedSelection() throws Throwable
    {
        createTable("CREATE TABLE %s (k int PRIMARY KEY, v int)");
        execute("INSERT INTO %s (k, v) VALUES (1, 42)");

        SelectStatement statement = (SelectStatement) parseStatement("SELECT v AS value FROM %s WHERE k = 1");
        SelectReferenceSource source = new SelectReferenceSource(statement);

        ColumnMetadata resolved = source.getColumn("value");
        assertNotNull(resolved);
        assertEquals("v", resolved.name.toString());
    }
}
