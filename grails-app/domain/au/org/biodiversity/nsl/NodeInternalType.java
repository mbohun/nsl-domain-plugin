package au.org.biodiversity.nsl;

/**
 * The internal type of a node serves as a discriminator (if we had hibernate
 * subclasses). It also allows us to distinguish between taxonimoc nodes and
 * profile data nodes without the system having to know which link types are
 * taxonomic and which are not.
 * 
 * To a degree, it's a bit of a hack and muddies the purity of the curated tree
 * algorithm. But whatever.
 * 
 * @author ibis
 *
 */

public enum NodeInternalType {
	/** System node */
	S,
	/** Temp node */
	Z,
	/** Taxonomic Tree node */
	T,
	/** Document (profile data) node */
	D,
	/** Value (literal or resource url) node */
	V;

	public boolean isTree() {
		return this == S || this == T;
	}

	public boolean isProfile() {
		return this == D || this == V;
	}
}
