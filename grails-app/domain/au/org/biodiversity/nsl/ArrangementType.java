package au.org.biodiversity.nsl;

public enum ArrangementType {
	/** the end tree */
	E("EndTree"),
	/** a public tree */
	P("Classification"),
	/** a user tree */
	U("UserArrangement"),
	/** a system temp tree */
	Z("TempArrangement");

	final String	uriId;

	ArrangementType(String uriId) {
		this.uriId = uriId;
	}

	public boolean isTree() {
		return this == E || this == P;
	}
}
